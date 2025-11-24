//
//  HoldingsManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-23.
//

import Foundation
import Combine
import FirebaseFirestore

import Foundation
import Combine
import FirebaseFirestore

class HoldingsManager: ObservableObject {
    static let shared = HoldingsManager()
    
    @Published var holdings: [Holding] = []
    @Published var holdingsDisplay: [HoldingDisplay] = []
    @Published var portfolio: Portfolio? = nil
    
    private let auth = AuthManager.shared
    private let db = Firestore.firestore()
    private let socket = WebSocketsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to stock price updates and recalculate display holdings
        socket.$stockPrices
            .sink { [weak self] stockPrices in
                //updates display holdings with live stock prices data
                self?.updateDisplayHoldings(with: stockPrices)
            }
            .store(in: &cancellables)
    }
    
    // Fetch holdings from Firestore
    func fetchHoldings(completion: @escaping (Result<[Holding], Error>) -> Void) {
        //get user id
        guard let uid = auth.currentUser?.id else {
            return completion(.failure(SimpleError("User not authenticated")))
        }
        //get the holdings from user
        db.collection("users").document(uid).collection("holdings")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    return completion(.failure(error))
                }
                // return holdings
                
                guard let documents = snapshot?.documents else {
                    return completion(.success([]))
                }
                
                let holdings = documents.compactMap { document -> Holding? in
                    try? document.data(as: Holding.self)
                }
                //save holdings into array
                self?.holdings = holdings
                //save display holdings into array
                self?.updateDisplayHoldings(with: self?.socket.stockPrices ?? [:])
                completion(.success(holdings))
            }
    }
    
    // Update display holdings with live StockPrice data
    private func updateDisplayHoldings(with stockPrices: [String: StockPrice]) {
        holdingsDisplay = holdings.compactMap { holding in
            guard let stockPrice = stockPrices[holding.symbol] else { return nil }
            return HoldingDisplay(holding: holding, stockPrice: stockPrice)
        }
        
        // Update portfolio whenever display holdings changee
        updatePortfolio()
    }
    
    //  Calculate portfolio from display holdings
    private func updatePortfolio() {
        guard !holdingsDisplay.isEmpty else {
            portfolio = nil
            return
        }
        portfolio = Portfolio(holdings: holdingsDisplay)
    }
    
    // Create or update holding based on transaction
    func updateHoldingFromTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void) {
        //fetch user id
        guard let uid = auth.currentUser?.id else {
            return completion(.failure(SimpleError("User is not authenticated")))
        }
        //get the holding reference by symbol
        let holdingRef = db.collection("users").document(uid).collection("holdings").document(transaction.symbol)
        
        //get the document
        holdingRef.getDocument { [weak self] document, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            var holding: Holding
            // check if holding exists
            if let document = document, document.exists,
               let existingHolding = try? document.data(as: Holding.self) {
                // Update existing holding
                holding = existingHolding
                //Check transaction type
                //buy
                if transaction.type == .buy {
                    let newTotalCost = holding.totalCost + transaction.totalCost
                    let newQuantity = holding.quantity + transaction.quantity
                    holding.quantity = newQuantity
                    holding.totalCost = newTotalCost
                    holding.avgCost = newTotalCost / Double(newQuantity)
                } else { // sell
                    holding.quantity -= transaction.quantity
                    holding.totalCost = holding.avgCost * Double(holding.quantity)
                }
                
            } else {
                // Create new holding
                holding = Holding(
                    id: transaction.symbol,
                    symbol: transaction.symbol,
                    quantity: transaction.quantity,
                    avgCost: transaction.price,
                    totalCost: transaction.totalCost
                )
            }
            
            // Delete holding if quantity is 0
            if holding.quantity <= 0 {
                holdingRef.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self?.fetchHoldings { _ in }
                        completion(.success(()))
                    }
                }
            } else {
                //save the holding
                do {
                    try holdingRef.setData(from: holding) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self?.fetchHoldings { _ in }
                            completion(.success(()))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
