//
//  Validators.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-06.
//

import Foundation

enum Validators{
    static func checkEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

//simple error
struct SimpleError: Error{
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var localizedDescription: String {
        return message
    }
}
