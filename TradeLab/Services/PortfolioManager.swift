//
//  PortfolioManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-09.
//

import Foundation
class PortfolioManager {
    var holdings: [Holding] = []
    var cash: Double = 10_000
    var livePrices: [String: Double] = [:] //symbol: price
    
    func updatePrice(symbol: String, price: Double){
        livePrices[symbol] = price
    }
    
    func totalValue() -> Double{
        var value = cash
        for holding in holdings{
            if let currentPrice = livePrices[holding.symbol]{
                value += currentPrice * holding.quantity
            }
        }
        return value
    }
    
    func unrealizedGain(holding: Holding, currentPrice: Double) -> Double{
        return (currentPrice - holding.avgBuyPrice) * holding.quantity
    }
    
    func unrealizedGainPercentage(holding: Holding, currentPrice: Double) -> Double{
        return ((currentPrice - holding.avgBuyPrice) / holding.avgBuyPrice) * 100
    }
    
    //TODO: functions Buy/Sell, RealizedGainsTracking, AvgBuyCalculation
}
