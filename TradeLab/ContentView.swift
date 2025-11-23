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
    @State private var isLoaded = false
    
    var body: some View {
        NavigationView {
            if auth.currentUser != nil {
                TabScreen()
                    .onAppear {
                        if !isLoaded {
                            transactions.fetchTransactions { result in
                                switch result {
                                case .success:
                                    isLoaded = true
                                case .failure(let error):
                                    print("Error fetching transactions: \(error.localizedDescription)")
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
}
