//
//  AppUser.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-05.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var picture: String? = nil
    var isActive: Bool = true
}
