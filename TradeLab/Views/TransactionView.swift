//
//  TransactionView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-11.
//
//
//  TODO:
//      - Ensure transactions load
//      - Kick to login if not logged in
//      - Make sure buttons work properly and   properly interact with the Firestore
//      - Fix any issues with spacing (if there are any)
//      - Add footer navbar


import SwiftUI
import FirebaseFirestore

struct TransactionView: View {
    @StateObject var auth = AuthManager.shared
    @StateObject var dmManager = DarkModeManager.shared
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.themeGradientStart, Color.themeGradientEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.themeOverlay)
                                .frame(width: 90, height: 90)
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.themePrimary)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Transaction History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themePrimary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Content Card
                    VStack(spacing: 20) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                                .padding(.vertical, 40)
                        } else if transactions.isEmpty {
                            // Empty State
                            VStack(spacing: 15) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.themeSecondary)
                                Text("No Transactions Yet")
                                    .font(.headline)
                                    .foregroundStyle(Color.themePrimary)
                                Text("Your trades will appear here")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.themeSecondary)
                            }
                            .padding(.vertical, 40)
                        } else {
                            // Transaction List
                            VStack(spacing: 15) {
                                ForEach(transactions) { transaction in
                                    TransactionCard(transaction: transaction)
                                }
                            }
                        }
                        
                        if let errorMessage = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(.subheadline)
                            }
                            .foregroundStyle(Color.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.themeOverlaySecondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .onAppear {
            dmManager.syncWithUser()
            loadTransactions()
        }
    }
    
    private func loadTransactions() {
        guard let userId = auth.currentUser?.id else {
            errorMessage = "No user logged in"
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("transactions")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load transactions: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No transactions found"
                    return
                }
                
                self.transactions = documents.compactMap { doc in
                    try? doc.data(as: Transaction.self)
                }
            }
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row - Symbol and Type Badge
            HStack {
                // Symbol
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text(transaction.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Buy/Sell Badge
                HStack(spacing: 6) {
                    Image(systemName: transaction.type == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.caption)
                    Text(transaction.type.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(transaction.type == .buy ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                .cornerRadius(15)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Transaction Details
            VStack(spacing: 8) {
                TransactionDetailRow(
                    label: "Quantity",
                    value: "\(transaction.quantity) shares",
                    icon: "number.circle.fill"
                )
                
                TransactionDetailRow(
                    label: "Price per Share",
                    value: String(format: "$%.2f", transaction.price),
                    icon: "dollarsign.circle.fill"
                )
                
                TransactionDetailRow(
                    label: "Total Cost",
                    value: String(format: "$%.2f", transaction.totalCost),
                    icon: "creditcard.fill"
                )
                
                TransactionDetailRow(
                    label: "Date",
                    value: formatDate(transaction.timestamp),
                    icon: "calendar.circle.fill"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TransactionDetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.white.opacity(0.6))
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    NavigationView {
        TransactionView()
    }
}
