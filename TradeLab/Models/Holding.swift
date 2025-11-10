//
//  Portfolio.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-08.
//

import Foundation
import FirebaseFirestore

// User's trade in portfolio

struct Holding: Codable, Identifiable {
    
    @DocumentID var id: String?
    let symbol: String
    var quantity: Double
    var avgBuyPrice: Double
}

