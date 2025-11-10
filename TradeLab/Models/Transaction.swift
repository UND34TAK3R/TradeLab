//
//  Transaction.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-09.
//

import Foundation
import FirebaseFirestore


//Transactions that users make 
struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?
    let symbol: String
    let quantity: Int
    let price: Double
    let timestamp: Date
    let totalCost: Double
    let type: TransactionType
}

enum TransactionType: String, Codable {
    case buy
    case sell
}
