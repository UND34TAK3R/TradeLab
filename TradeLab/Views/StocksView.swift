//
//  StocksView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-12.
//
//  TODO:
//      - Testing
//      - Add TabScreen
//

import SwiftUI

struct StocksView: View {
    @StateObject private var socket = WebSocketsManager.shared
    @StateObject private var dmManager = DarkModeManager.shared
    @State private var searchText = ""
    @State private var isConnected = false
    @State private var lastTradeCount = 0
    @State private var isMarketOpen = true
    @State private var noTradesTimer: Timer?
    
    // Filter stocks
    var filteredStocks: [StockPrice] {
        let stocks = Array(socket.stockPrices.values)
        if searchText.isEmpty {
            return stocks.sorted { $0.symbol < $1.symbol }
        }
        return stocks.filter {
            $0.symbol.lowercased().contains(searchText.lowercased())
        }
        .sorted { $0.symbol < $1.symbol }
    }
    var body: some View {
        // BG
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.themeGradientStart, Color.themeGradientEnd]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            
            // Heading
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Market Watch")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.themePrimary)
                            
                            // Check market connection
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(isMarketOpen ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(isMarketOpen ? "Online" : "Offline")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.themeSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Market icon on the right
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 50, height: 50)
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.themePrimary)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.themeSecondary)
                        TextField("Search stocks...", text: $searchText)
                                .foregroundStyle(Color.themePrimary)
                                .autocapitalization(.allCharacters)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = ""}) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.themeSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.themeOverlay)
                    .cornerRadius(25)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 20)
                }
                .background(Color.clear)
                
                // Stocks
                if filteredStocks.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.themeSecondary)
                        Text(searchText.isEmpty ? "" : "No stocks found")
                            .font(.headline)
                            .foregroundStyle(Color.themeSecondary)
                        
                        if !isMarketOpen {
                            Text("The market is currently closed. Please come back between 8:00 AM and 4:00 PM EST.")
                                .font(.subheadline)
                                .foregroundStyle(Color.themeSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        if searchText.isEmpty && !isConnected {
                            ProgressView()
                                .tint(Color.themePrimary)
                                .scaleEffect(1.5)
                                .padding(.top, 10)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStocks, id: \.symbol) { stockPrice in
                                NavigationLink(destination: StockDetailView(symbol: stockPrice.symbol)) {
                                    StockRowView(stock: stockPrice)
                            }
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                }
            }
        }
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .onAppear {
            dmManager.syncWithUser()
            if !isConnected {
                socket.startCollectingTrades()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isConnected = true
                    monitorTrades()
                }
            }
        }
        .onDisappear {
            noTradesTimer?.invalidate()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func monitorTrades() {
        // Check every 5 secs if there is a new trade
        noTradesTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
            _ in
            let currentTradeCount = socket.trades.count
            
            if isConnected && currentTradeCount == lastTradeCount && currentTradeCount == 0 {
                isMarketOpen = false
            } else if currentTradeCount == lastTradeCount && currentTradeCount > 0 {
                if let lastTrade = socket.trades.last {
                    let lastTradeTimeInSecs = Double(lastTrade.timestamp)
                    let lastTradeDate = Date(timeIntervalSince1970: lastTradeTimeInSecs)
                    let timeSinceLastTrade = Date().timeIntervalSince(lastTradeDate)
                    if timeSinceLastTrade > 30 {
                        isMarketOpen = false
                    }
                }
            } else {
                // Receive trades
                isMarketOpen = true
            }
            lastTradeCount = currentTradeCount
        }
    }
}

struct StockRowView: View {
    let stock : StockPrice
    
    private var priceChangeColor: Color {
        guard let change = stock.priceChange else { return .white }
        return change >= 0 ? .green : .red
    }
    
    private var priceChangeIcon: String {
        guard let change = stock.priceChange else { return "minus" }
        return change >= 0 ? "arrow.up.right" : "arrow.down.right"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.themeOverlay)
                    .frame(width: 55, height: 55)
                Text(String(stock.symbol.prefix(2)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themePrimary)
            }
            
            // Stock info
            VStack(alignment: .leading, spacing: 5) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themePrimary)
                
                if let previous = stock.previousPrice {
                    Text("Prev: $\(String(format: "%.2f", previous))")
                        .font(.caption)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("$\(String(format: "%.2f", stock.currentPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themePrimary)
                
                if let percentageChange = stock.percentageChange {
                    HStack(spacing: 4) {
                        Image(systemName: priceChangeIcon)
                            .font(.caption)
                        
                        Text("\(String(format: "%.2f", abs(percentageChange)))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(priceChangeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .cornerRadius(8)
                    .background(priceChangeColor.opacity(0.2))
                }
            }
        }
        .padding()
        .background(Color.themeOverlaySecondary)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationView {
        StocksView()
    }
}
