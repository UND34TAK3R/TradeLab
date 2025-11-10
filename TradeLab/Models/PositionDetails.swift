//
//  PositionDetails.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-09.
//

import Foundation


// Stats for one holding
struct PositionDetails : Codable{
    let holding: Holding
    let currentPrice: Double
    let currentValue: Double
    let unrealizedGain: Double
    let unrealizedGainPercent: Double
    let dayChange: Double
    let dayChangePercent: Double
}
