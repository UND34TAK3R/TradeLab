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
    var Volume: Double // v
    var timestamp: Int64 //TBD
    let conditions: [String]?
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "p"
        case symbol = "s"
        case Volume = "v"
        case timestamp = "t"
        case conditions = "c"
    }
}

struct TradeResponse: Codable {
    let data: [Trade]?
    let type: String
}


