//
//  Secrets.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-19.
//

import Foundation

enum Secrets {
    static let FHAPIKey = Bundle.main.object(forInfoDictionaryKey: "FINNHUB_KEY") as? String ?? ""
}
