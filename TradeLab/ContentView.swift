//
//  ContentView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-28.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthManager.shared
    @StateObject private var socket = WebSocketsManager.shared
    @StateObject private var transactions = TransactionsManager.shared
    @StateObject private var holdings = HoldingsManager.shared
    @StateObject private var trading = TradingManager.shared
    @State private var isLoaded = false
    
    var body: some View {
        NavigationView {
            if auth.currentUser != nil {
                TabScreen()
                    .onAppear {
                        if !isLoaded {
                            isLoaded = true 
                            
                            // Fetch both concurrently
                            transactions.fetchTransactions { result in
                                switch result {
                                case .success:
                                    print("Transactions loaded successfully")
                                case .failure(let error):
                                    print("Error fetching transactions: \(error.localizedDescription)")
                                }
                            }
                            
                            holdings.fetchHoldings { result in
                                switch result {
                                case .success:
                                    print("Holdings loaded successfully")
                                case .failure(let error):
                                    print("Error fetching holdings: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(WebSocketsManager())
        .environmentObject(TransactionsManager())
        .environmentObject(HoldingsManager())
}
