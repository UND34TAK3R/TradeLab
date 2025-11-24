//
//  StockPrice.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-21.
//

import Foundation
struct StockPrice: Equatable {
    let symbol: String
    var currentPrice: Double
    var previousPrice: Double?
    var timestamp: Date
    
    var percentageChange: Double? {
        guard let previous = previousPrice, previous > 0 else {
            return nil
        }
        return ((currentPrice - previous)/previous) * 100
    }
    var priceChange: Double? {
        guard let previous = previousPrice else {
            return nil
        }
        return currentPrice - previous
    }
}
