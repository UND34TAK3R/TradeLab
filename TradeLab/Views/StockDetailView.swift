//
//  StockDetailView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-12.
//
//
//  TODO:
//      

import SwiftUI

struct StockDetailView: View {
    let symbol: String
    @StateObject private var webSocketManager = WebSocketsManager.shared
    @StateObject private var transactionManager = TransactionsManager.shared
    @StateObject private var holdingsManager = HoldingsManager.shared
    @StateObject private var auth = AuthManager.shared
    @StateObject private var dmManager = DarkModeManager.shared
    
    @State private var showTransactionsSheet = false
    @State private var transactionType: TransactionType = .buy
    @State private var quantity: String = ""
    @State private var errorMsg: String?
    @State private var successMsg: String?
    @Environment(\.dismiss) var dismiss
    
    private var stockPrice: StockPrice? {
        webSocketManager.stockPrices[symbol]
    }
    
    private var holding: HoldingDisplay? {
        holdingsManager.holdingsDisplay.first { $0.symbol == symbol}
    }
    
    private var recentTrades: [Trade] {
        webSocketManager.trades.filter { $0.symbol == symbol }
            .suffix(5)
            .reversed()
    }
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.themeGradientStart, Color.themeGradientEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.themeOverlay)
                            .frame(width: 80, height: 80)
                        
                        Text(String(symbol.prefix(2)))
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themePrimary)
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Text(symbol)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.themePrimary)
                    
                    if let stock = stockPrice {
                        VStack(spacing: 8) {
                            Text("$\(String(format: "%.2f", stock.currentPrice))")
                                .font(.system(size: 48))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.themePrimary)
                            
                            if let percentChange = stock.percentageChange, let priceChange = stock.priceChange {
                                HStack(spacing: 8) {
                                    Image(systemName: priceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.headline)
                                    Text("\(priceChange >= 0 ? "+" : "")\(String(format: "%.2f", priceChange))")
                                    Text("(\(priceChange >= 0 ? "+" : "")\(String(format: "%.2f", percentChange))%)")
                                        .font(.headline)
                                }
                                .foregroundStyle(priceChange >= 0 ? Color.green : Color.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background((priceChange >= 0 ? Color.green : Color.red).opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                    } else {
                        ProgressView()
                            .tint(Color.primary)
                            .scaleEffect(1.5)
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // Holdings
                if let holding = holding {
                    VStack(spacing: 15) {
                        Text("Your Position")
                            .font(.headline)
                            .foregroundStyle(Color.themeSecondary)
                        
                        HStack(spacing: 30) {
                            VStack(spacing: 5) {
                                Text("Shares")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("\(holding.quantity)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            
                            VStack(spacing: 5) {
                                Text("Avg Cost")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("$\(String(format: "%.2f", holding.avgCost))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            
                            VStack(spacing: 5) {
                                Text("Total P/L")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("$\(String(format: "%.2f", holding.unrealizedPnL))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(holding.unrealizedPnL >= 0 ? Color.green : Color.red)
                            }
                        }
                        
                        HStack(spacing: 15) {
                            VStack(spacing: 5) {
                                Text("Market Value")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("$\(String(format: "%.2f", holding.totalValue))")
                                    .font(.headline)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            
                            VStack(spacing: 5) {
                                Text("Total Cost")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("$\(String(format: "%.2f", holding.totalCost))")
                                    .font(.headline)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            
                            VStack(spacing: 5) {
                                Text("Return")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text("\(String(format: "%.2f", holding.unrealizedPnLPercent))%")
                                    .font(.headline)
                                    .foregroundStyle(holding.unrealizedPnLPercent >= 0 ? Color.green : Color.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color.themeOverlay)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
                
                // Action buttons (buy/sell)
                HStack(spacing: 15) {
                    Button(action: {
                        transactionType = .buy
                        showTransactionsSheet = true
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Buy")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        transactionType = .sell
                        showTransactionsSheet = true
                    }) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("Sell")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(holding == nil || (holding?.quantity ?? 0) == 0)
                    .opacity(holding == nil || (holding?.quantity ?? 0) == 0 ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                
                // Display balance
                if let user = auth.currentUser {
                    HStack(spacing: 8) {
                        Image(systemName: "creditcard.fill")
                            .font(.headline)
                        Text("Balance:")
                            .font(.headline)
                        Text("$\(String(format: "%.2f", user.wallet))")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color.themePrimary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.themeOverlay)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Error/Success Msg
                if let error = errorMsg {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.red)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                if let success = successMsg {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(success)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.green)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                // Recent Trades
                if !recentTrades.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Trades")
                            .font(.headline)
                            .foregroundStyle(Color.themePrimary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(recentTrades.enumerated()), id: \.element.timestamp) { index, trade in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("$\(String(format: "%.2f", trade.currentPrice))")
                                            .font(.headline)
                                            .foregroundStyle(Color.themePrimary)
                                        
                                        Text(formatTimestamp(trade.timestamp))
                                            .font(.caption)
                                            .foregroundStyle(Color.themeSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Vol: \(String(format: "%.2f", trade.Volume))")
                                            .font(.caption)
                                            .foregroundStyle(Color.themeSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.themeOverlay)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                Spacer(minLength: 20)
            }
        }
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .sheet(isPresented: $showTransactionsSheet) {
            TransactionSheetView(
                symbol: symbol,
                transactionType: transactionType,
                currentPrice: stockPrice?.currentPrice ?? 0,
                maxShares: holding?.quantity ?? 0,
                onComplete: { success, message in
                    if success {
                        successMsg = message
                        errorMsg = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            successMsg = nil
                        }
                    } else {
                        errorMsg = message
                        successMsg = nil
                    }
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            dmManager.syncWithUser()
        }
    }
}

private func formatTimestamp(_ timestamp: Int64) -> String {
    let date = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

struct TransactionSheetView: View {
    let symbol: String
    let transactionType: TransactionType
    let currentPrice: Double
    let maxShares: Int
    var onComplete: (Bool, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var quantity: String = ""
    @StateObject private var transactionsManager = TransactionsManager.shared
    @StateObject private var auth = AuthManager.shared
    @StateObject private var dmManager = DarkModeManager.shared
    
    private var totalCost: Double {
        guard let qty = Int(quantity) else { return 0 }
        return Double(qty) * currentPrice
    }
    
    private var isValidTransaction: Bool {
        guard let qty = Int(quantity), qty > 0 else { return false }
        if transactionType == .sell {
            return qty <= maxShares
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        Text("\(transactionType == .buy ? "Buy" : "Sell") \(symbol)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themePrimary)
                        
                        Text("Current Price: $\(String(format: "%.2f", currentPrice))")
                            .font(.headline)
                            .foregroundStyle(Color.themeSecondary)
                        
                        if transactionType == .sell {
                            Text("Available: \(maxShares) shares")
                                .font(.subheadline)
                                .foregroundStyle(Color.themeSecondary)
                        }
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quantity")
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                            
                            TextField("Number of shares", text: $quantity)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.themeOverlay)
                                .foregroundStyle(Color.themePrimary)
                                .cornerRadius(10)
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Total Cost:")
                                    .font(.headline)
                                Spacer()
                                Text("$\(String(format: "%.2f", totalCost))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(Color.themePrimary)
                        }
                        .padding()
                        .background(Color.themeOverlaySecondary)
                        .cornerRadius(12)
                        
                        Button(action: executeTransaction) {
                            Text(transactionType == .buy ? "Confirm Purchase" : "Confirm Sale")
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: transactionType == .buy ?
                                                           [Color.green.opacity(0.8), Color.green] :
                                                            [Color.red.opacity(0.8), Color.red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .disabled(!isValidTransaction)
                        .opacity(isValidTransaction ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                    .background(Color.themeOverlaySecondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                dmManager.syncWithUser()
            }
        }
    }
    
    private func executeTransaction() {
        guard let qty = Int(quantity), isValidTransaction else { return }
        
        transactionsManager.createTransaction(
            symbol: symbol,
            quantity: qty,
            date: Date(),
            price: currentPrice,
            type: transactionType,
            totalCost: totalCost
        ) { result in
            switch result {
            case .success:
                onComplete(true, "\(transactionType == .buy ? "Purchase" : "Sale") successful!")
                dismiss()
            case .failure(let error):
                onComplete(false, error.localizedDescription)
                dismiss()
            }
        }
    }
}

#Preview {
    StockDetailView(symbol: "AAPL")
}
