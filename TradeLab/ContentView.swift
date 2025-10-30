//
//  ContentView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        NavigationView{
            if authManager.user != nil {
                PortfolioView()
            }
            else{
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
