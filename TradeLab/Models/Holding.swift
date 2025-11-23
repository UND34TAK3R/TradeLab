//
//  Portfolio.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-08.
//
import Foundation
import FirebaseFirestore

// Firestore model
struct Holding: Codable, Identifiable {
    @DocumentID var id: String?
    var symbol: String
    var quantity: Int
    var avgCost: Double
    var totalCost: Double
}

// Display model
struct HoldingDisplay: Identifiable {
    let id: String
    let symbol: String
    let quantity: Int
    let avgCost: Double
    let totalCost: Double
    
    // Live data from StockPrice
    let stockPrice: StockPrice
    
    var currentPrice: Double {
        stockPrice.currentPrice
    }
    
    var totalValue: Double {
        Double(quantity) * currentPrice
    }
    
    var unrealizedPnL: Double {
        totalValue - totalCost
    }
    
    var unrealizedPnLPercent: Double {
        guard totalCost > 0 else { return 0 }
        return (unrealizedPnL / totalCost) * 100
    }
    
    var percentageChange: Double? {
        stockPrice.percentageChange
    }
    
    var priceChange: Double? {
        stockPrice.priceChange
    }
    
    // Initialize from Holding + StockPrice
    init(holding: Holding, stockPrice: StockPrice) {
        self.id = holding.id ?? ""
        self.symbol = holding.symbol
        self.quantity = holding.quantity
        self.avgCost = holding.avgCost
        self.totalCost = holding.totalCost
        self.stockPrice = stockPrice
    }
}
