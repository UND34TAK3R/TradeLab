//
//  Portfolio.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-23.
//
import Foundation

struct Portfolio {
    var holdings: [HoldingDisplay]
    var totalCost: Double
    var totalValue: Double
    var unrealizedPL: Double
    var unrealizedPLPercent: Double
    var weights: [String: Double]
    
    // Computed properties
    init(holdings: [HoldingDisplay]) {
        self.holdings = holdings
        self.totalCost = Portfolio.calculateTotalCost(holdings: holdings)
        self.totalValue = Portfolio.calculateTotalValue(holdings: holdings)
        self.unrealizedPL = self.totalValue - self.totalCost
        self.unrealizedPLPercent = self.totalCost > 0 ? (self.unrealizedPL / self.totalCost) * 100 : 0
        self.weights = Portfolio.calculateWeights(holdings: holdings, totalValue: self.totalValue)
    }
    
    // methods
    static func calculateTotalValue(holdings: [HoldingDisplay]) -> Double {
        holdings.reduce(0) { $0 + $1.totalValue }
    }
    
    static func calculateTotalCost(holdings: [HoldingDisplay]) -> Double {
        holdings.reduce(0) { $0 + $1.totalCost }
    }
    
    static func calculateWeights(holdings: [HoldingDisplay], totalValue: Double) -> [String: Double] {
        guard totalValue > 0 else { return [:] }
        
        var weights: [String: Double] = [:]
        for holding in holdings {
            weights[holding.symbol] = (holding.totalValue / totalValue) * 100
        }
        return weights
    }
}
