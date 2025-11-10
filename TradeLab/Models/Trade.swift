//
//  Trade.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-08.
//

import Foundation

// The trades that we get from web socket
public struct Trade: Codable {
    var symbol: String // s
    var currentPrice: Double //p
    var Volume: Int // v
    var timestamp: TimeInterval //TBD
}
