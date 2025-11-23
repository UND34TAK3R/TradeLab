//
//  TransactionsManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-23.
//

import Foundation
import Combine
import FirebaseFirestore

class TransactionsManager: ObservableObject {
    //Singleton pattern
    static let shared = TransactionsManager()
    @Published var transactions: [Transaction] = []
    let auth = AuthManager.shared
    private let db = Firestore.firestore()
    
    
    func createTransaction(symbol: String, quantity: Int, date: Date, price: Double, type: TransactionType, totalCost: Double, completion: @escaping (Result<Void, Error>) -> Void){
        let id = UUID().uuidString
        guard let uid = self.auth.currentUser?.id else{return completion(.failure(SimpleError("Unable to find user ID")))}
        let transaction = Transaction(id: id, symbol: symbol, quantity: quantity, price: price, timestamp: date, totalCost: totalCost, type: type)
        
        do{
            try self.db.collection("users").document(uid).collection("transactions").document(id).setData(from: transaction){
                error in
                if let error = error{
                    return completion(.failure(error))
                }
                //refetch transactions on success
                self.fetchTransactions{result in
                    switch result {
                    case .success(let transactions):
                        self.transactions = transactions
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }catch{
            completion(.failure(error))
        }
    }
    
    func deleteTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void){
        guard let uid = self.auth.currentUser?.id else{return completion(.failure(SimpleError("Unable to find User id")))}
        guard let id = transaction.id else {
            return completion(.failure(SimpleError("Unable to find Transaction ID")))
        }
        self.db.collection("users").document(uid).collection("transactions").document(id).delete(){
            error in
            if let error = error{
                return completion(.failure(error))
            }
            //refetch transactions on success
            self.fetchTransactions{result in
                switch result {
                case .success(let transactions):
                    self.transactions = transactions
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void){
        guard let uid = auth.currentUser?.id else {
            return completion(.failure(SimpleError("Unable to find User id")))
        }
        db.collection("users").document(uid).collection("transactions")
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    return completion(.failure(error))
                }
                guard let documents = querySnapshot?.documents else {
                    return completion(.success([]))
                }
                let transactions = documents.compactMap { document -> Transaction? in
                    try? document.data(as: Transaction.self)
                }
                self.transactions = transactions
                completion(.success(transactions))
            }
    }
}
