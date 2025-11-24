//
//  DarkModeManager.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-24.
//

import Foundation
import Combine

class DarkModeManager: ObservableObject {
    static let shared = DarkModeManager()
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    func syncWithUser() {
        if let userDarkMode = AuthManager.shared.currentUser?.isDarkMode {
            self.isDarkMode = userDarkMode
        }
    }
    
    func updateDarkMode(_ isDark: Bool) {
        self.isDarkMode = isDark
        
        // Update AuthManager
        AuthManager.shared.updateIsDarkMode(isDarkMode: isDark) { result in
            switch result {
            case .success:
                print("Dark mode updated successfully internally.")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
