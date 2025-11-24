//
//  TradingManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-23.
//

import Foundation
import Combine
import FirebaseFirestore

class TradingManager: ObservableObject {
    static let shared = TradingManager()
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let transactions = TransactionsManager.shared
    private let holdingsM = HoldingsManager.shared
    private let auth = AuthManager.shared
    
    private init() {}
    
    //Buy stocks
    func buyStock(symbol: String, quantity: Int, price: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            guard quantity > 0 else {
                return completion(.failure(SimpleError("Quantity must be greater than 0")))
            }
            
            guard price > 0 else {
                return completion(.failure(SimpleError("Price must be greater than 0")))
            }
            
            let totalCost = Double(quantity) * price
            
            // Check if user has enough funds
            guard let wallet = auth.currentUser?.wallet else {
                return completion(.failure(SimpleError("Unable to access wallet")))
            }
            
            guard wallet >= totalCost else {
                errorMessage = "Insufficient funds. You need $\(String(format: "%.2f", totalCost)) but only have $\(String(format: "%.2f", wallet))"
                return completion(.failure(SimpleError("Insufficient funds")))
            }
            
            isProcessing = true
            errorMessage = nil
            successMessage = nil
            
            // Deduct from wallet
            updateWallet(amount: -totalCost) { [weak self] walletResult in
                guard let self = self else { return }
                
                switch walletResult {
                case .success:
                    // Create transaction
                    self.transactions.createTransaction(
                        symbol: symbol.uppercased(),
                        quantity: quantity,
                        date: Date(),
                        price: price,
                        type: .buy,
                        totalCost: totalCost
                    ) { result in
                        self.isProcessing = false
                        
                        switch result {
                        case .success:
                            self.successMessage = "Successfully bought \(quantity) shares of \(symbol) at $\(String(format: "%.2f", price))"
                            completion(.success(()))
                        case .failure(let error):
                            // Rollback wallet if transaction fails
                            self.updateWallet(amount: totalCost) { _ in }
                            self.errorMessage = error.localizedDescription
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    self.isProcessing = false
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    
    // Sell stock
        func sellStock(symbol: String, quantity: Int, price: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            guard quantity > 0 else {
                return completion(.failure(SimpleError("Quantity must be greater than 0")))
            }
            
            guard price > 0 else {
                return completion(.failure(SimpleError("Price must be greater than 0")))
            }
            
            // Validate user has enough shares
            guard let holding = holdingsM.holdings.first(where: { $0.symbol == symbol.uppercased() }) else {
                errorMessage = "You don't own any shares of \(symbol)"
                return completion(.failure(SimpleError("You don't own any shares of \(symbol)")))
            }
            
            guard holding.quantity >= quantity else {
                errorMessage = "Insufficient shares. You own \(holding.quantity) shares of \(symbol)"
                return completion(.failure(SimpleError("Insufficient shares. You own \(holding.quantity) shares.")))
            }
            
            isProcessing = true
            errorMessage = nil
            successMessage = nil
            
            let totalProceeds = Double(quantity) * price
            
            // Create transaction first
            transactions.createTransaction(
                symbol: symbol.uppercased(),
                quantity: quantity,
                date: Date(),
                price: price,
                type: .sell,
                totalCost: totalProceeds
            ) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    // Add proceeds to wallet
                    self.updateWallet(amount: totalProceeds) { walletResult in
                        self.isProcessing = false
                        
                        switch walletResult {
                        case .success:
                            self.successMessage = "Successfully sold \(quantity) shares of \(symbol) at $\(String(format: "%.2f", price))"
                            completion(.success(()))
                        case .failure(let error):
                            self.errorMessage = "Trade executed but wallet update failed: \(error.localizedDescription)"
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    self.isProcessing = false
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    
    
    private func updateWallet(amount: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let uid = auth.currentUser?.id else {
                return completion(.failure(SimpleError("User not authenticated")))
            }
            
            guard let currentWallet = auth.currentUser?.wallet else {
                return completion(.failure(SimpleError("Unable to access wallet")))
            }
            
            let newBalance = currentWallet + amount
            
            guard newBalance >= 0 else {
                return completion(.failure(SimpleError("Insufficient funds")))
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).updateData([
                "wallet": newBalance
            ]) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Update local user object
                    self?.auth.currentUser?.wallet = newBalance
                    completion(.success(()))
                }
            }
        }
    
    // Get max sellable quantity for a symbol
    func getMaxSellableQuantity(for symbol: String) -> Int {
        holdingsM.holdings.first(where: { $0.symbol == symbol.uppercased() })?.quantity ?? 0
    }
    
    // Calculate total cost for a trade
    func calculateTotalCost(quantity: Int, price: Double) -> Double {
        Double(quantity) * price
    }
    
    
    func calculatePotentialPL(symbol: String, quantity: Int, sellPrice: Double) -> (pnl: Double, pnlPercent: Double)? {
        
        guard let holding = holdingsM.holdings.first(where: { $0.symbol == symbol.uppercased() }) else {
            return nil
        }
            
        let costBasis = holding.avgCost * Double(quantity)
        let saleValue = Double(quantity) * sellPrice
        let pl = saleValue - costBasis
        let plPercent = (pl / costBasis) * 100
            
        return (pl, plPercent)
    }
    
    // Get current wallet balance
    func getCurrentWalletBalance() -> Double {
        auth.currentUser?.wallet ?? 0
    }
        
        // Check if user can afford purchase
    func canAffordPurchase(totalCost: Double) -> Bool {
        guard let wallet = auth.currentUser?.wallet else { return false }
        return wallet >= totalCost
    }

        
    // Clear messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
