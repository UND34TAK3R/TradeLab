//
//  PortfolioStatistics.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-09.
//

import Foundation


    //Statistics for the whole protfolio (all user holdings)
struct PortfolioStatistics: Codable {
    var totalValue: Double
    var cash: Double
    var stockValue: Double
    var totalGainLoss: Double
    var totalGainLossPercentage: Double
    var realizedGain: Double
}
