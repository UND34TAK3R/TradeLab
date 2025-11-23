//
//  StocksView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-12.
//
//
//  TODO:
//      - Stock page once we integrate it
//

import SwiftUI

struct StocksView: View {
    @StateObject private var socket = WebSocketsManager.shared
    @State private var searchText = ""
    @State private var isConnected = false
    
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
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
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
                                .foregroundStyle(Color.white)
                            
                            // Check market connection
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(isConnected ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(isConnected ? "Online" : "Offline")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.9))
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
                                .foregroundStyle(Color.white)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.white.opacity(0.7))
                        TextField("Search stocks...", text: $searchText)
                                .foregroundStyle(Color.white)
                                .autocapitalization(.allCharacters)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = ""}) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
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
                            .foregroundStyle(Color.white.opacity(0.7))
                        Text(searchText.isEmpty ? "Fetching stocks..." : "No stocks found")
                            .font(.headline)
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        if searchText.isEmpty && !isConnected {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                                .padding(.top, 10)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStocks, id: \.symbol) {
                                stock in
                                StockRowView(stock: stock)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                }
            }
        }
        .onAppear {
            if !isConnected {
                socket.startCollectingTrades()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isConnected = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 55, height: 55)
                Text(String(stock.symbol.prefix(2)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
            }
            
            // Stock info
            VStack(alignment: .leading, spacing: 5) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                
                if let previous = stock.previousPrice {
                    Text("Prev: $\(String(format: "%.2f", previous))")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("$\(String(format: "%.2f", stock.currentPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
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
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationView {
        StocksView()
    }
}
