//
//  PortfolioView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-10-29.
//
//
//  TODO:
//      - Add footer nav
//      - Kick user to login if not logged in
//      - Make logout outside of the RoundedRectagle content
//      - Ensure collections work properly
//      - Change the Circle icon to the user's profile picture
//      - Move logout to another page (most likely profileview)
//
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PortfolioView: View {
    @StateObject var auth = AuthManager.shared
    @StateObject var holdingsManager = HoldingsManager.shared
    @StateObject var webSocketManager = WebSocketsManager.shared
    @StateObject var dmManager = DarkModeManager.shared
    
    @State private var portfolio: Portfolio?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showLogoutAlert = false
    
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
                    // Profile Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.themeOverlay)
                                .frame(width: 90, height: 90)
                            
                            if let pictureString = auth.currentUser?.picture,
                               let imageData = Data(base64Encoded: pictureString),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.themePrimary)
                            }
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Welcome back, \(auth.currentUser?.displayName ?? "user")!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themePrimary)

                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Portfolio Statistics Card
                    if let portfolio = portfolio {
                        VStack(spacing: 20) {
                            Text("Portfolio Overview")
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Total Value
                            VStack(spacing: 8) {
                                Text("Total Portfolio Value")
                                    .font(.caption)
                                    .foregroundStyle(Color.themeSecondary)
                                Text(String(format: "$%.2f", portfolio.totalValue))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(Color.themePrimary)
                            }
                            .padding(.vertical, 10)
                            
                            Divider()
                                .background(Color.themeBorderSecondary)
                            
                            // Stats Grid
                            VStack(spacing: 12) {
                                HStack(spacing: 15) {
                                    StatCard(
                                        title: "Total Cost",
                                        value: String(format: "$%.2f", portfolio.totalCost),
                                        icon: "dollarsign.circle.fill",
                                        color: .blue
                                    )
                                    
                                    StatCard(
                                        title: "Market Value",
                                        value: String(format: "$%.2f", portfolio.totalValue),
                                        icon: "chart.bar.fill",
                                        color: .green
                                    )
                                }
                                
                                HStack(spacing: 15) {
                                    StatCard(
                                        title: "Unrealized P/L",
                                        value: String(format: "$%.2f", portfolio.unrealizedPL),
                                        icon: portfolio.unrealizedPL >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                        color: portfolio.unrealizedPL >= 0 ? .green : .red
                                    )
                                    
                                    StatCard(
                                        title: "Return %",
                                        value: String(format: "%.2f%%", portfolio.unrealizedPLPercent),
                                        icon: "percent",
                                        color: portfolio.unrealizedPLPercent >= 0 ? .green : .red
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 40)
                        .background(Color.themeOverlaySecondary)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    }
                    
                    // Holdings Section
                    VStack(spacing: 20) {
                        HStack {
                            Text("Your Holdings")
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                            Spacer()
                            Text("\(holdingsManager.holdingsDisplay.count) stocks")
                                .font(.subheadline)
                                .foregroundStyle(Color.themeSecondary)
                        }
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color.themePrimary)
                                .padding(.vertical, 40)
                        } else if holdingsManager.holdingsDisplay.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "chart.line.flattrend.xyaxis")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.themeSecondary)
                                Text("No Holdings Yet")
                                    .font(.headline)
                                    .foregroundStyle(Color.themePrimary)
                                Text("Start trading to build your portfolio")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.themeSecondary)
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(holdingsManager.holdingsDisplay) { holding in
                                    NavigationLink(destination: StockDetailView(symbol: holding.symbol)) {
                                        HoldingCard(holding: holding)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.themeOverlaySecondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
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
                    
                    Spacer(minLength: 20)
                    
                    
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            dmManager.syncWithUser()
            loadPortfolioData()
        }
        .onChange(of: holdingsManager.holdingsDisplay) { newHoldings in
            updatePortfolio(with: newHoldings)
        }
    }
    
    private func loadPortfolioData() {
        guard let userId = auth.currentUser?.id else {
            errorMessage = "No user logged in"
            isLoading = false
            return
        }
        
        // Fetch holdings from HoldingsManager
        holdingsManager.fetchHoldings { result in
            isLoading = false
            
            switch result {
            case .success(let holdings):
                print("Successfully loaded \(holdings.count) holdings")
                // Portfolio will be updated via onChange
            case .failure(let error):
                self.errorMessage = "Failed to load holdings: \(error.localizedDescription)"
            }
        }
    }
    
    private func updatePortfolio(with holdings: [HoldingDisplay]) {
        guard !holdings.isEmpty else {
            portfolio = nil
            return
        }
        portfolio = Portfolio(holdings: holdings)
    }
    
    private func handleLogout() {
        let result = auth.signOut()
        switch result {
        case .success:
            print("Logout successful")
        case .failure(let error):
            self.errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color.opacity(0.8))
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.themeSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.themePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.themeOverlay)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeBorderSecondary, lineWidth: 1)
        )
    }
}

struct HoldingCard: View {
    let holding: HoldingDisplay
    
    var body: some View {
        HStack {
            // Symbol Circle
            ZStack {
                Circle()
                    .fill(Color.themeOverlay)
                    .frame(width: 50, height: 50)
                
                Text(String(holding.symbol.prefix(2)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themePrimary)
            }
            
            // Symbol and quantity
            VStack(alignment: .leading, spacing: 4) {
                Text(holding.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themePrimary)
                
                Text("\(holding.quantity) shares")
                    .font(.caption)
                    .foregroundStyle(Color.themeSecondary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", holding.currentPrice))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themePrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: holding.unrealizedPnL >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text(String(format: "$%.2f", abs(holding.unrealizedPnL)))
                        .font(.caption)
                }
                .foregroundStyle(holding.unrealizedPnL >= 0 ? Color.green : Color.red)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.themeSecondary)
                .padding(.leading, 8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        PortfolioView()
    }
}
