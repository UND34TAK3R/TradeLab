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
    @State private var holdings: [Holding] = []
    @State private var portfolioStats: PortfolioStatistics?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
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
                                .fill(Color.white.opacity(0.3))
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
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Welcome back, \(auth.currentUser?.displayName ?? "user")!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text(auth.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Portfolio Statistics Card
                    if let stats = portfolioStats {
                        VStack(spacing: 20) {
                            Text("Portfolio Overview")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Total Value
                            VStack(spacing: 8) {
                                Text("Total Portfolio Value")
                                    .font(.caption)
                                    .foregroundStyle(Color.white.opacity(0.7))
                                Text(String(format: "$%.2f", stats.totalValue))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(.vertical, 10)
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                            
                            // Stats Grid
                            VStack(spacing: 12) {
                                HStack(spacing: 15) {
                                    StatCard(
                                        title: "Cash",
                                        value: String(format: "$%.2f", stats.cash),
                                        icon: "dollarsign.circle.fill",
                                        color: .green
                                    )
                                    
                                    StatCard(
                                        title: "Stock Value",
                                        value: String(format: "$%.2f", stats.stockValue),
                                        icon: "chart.bar.fill",
                                        color: .blue
                                    )
                                }
                                
                                HStack(spacing: 15) {
                                    StatCard(
                                        title: "Total Gain/Loss",
                                        value: String(format: "$%.2f", stats.totalGainLoss),
                                        icon: stats.totalGainLoss >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                        color: stats.totalGainLoss >= 0 ? .green : .red
                                    )
                                    
                                    StatCard(
                                        title: "Percentage",
                                        value: String(format: "%.2f%%", stats.totalGainLossPercentage),
                                        icon: "percent",
                                        color: stats.totalGainLossPercentage >= 0 ? .green : .red
                                    )
                                }
                                
                                StatCard(
                                    title: "Realized Gain",
                                    value: String(format: "$%.2f", stats.realizedGain),
                                    icon: "checkmark.circle.fill",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 40)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    }
                    
                    // Holdings Section
                    VStack(spacing: 20) {
                        HStack {
                            Text("Your Holdings")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(holdings.count) stocks")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                                .padding(.vertical, 40)
                        } else if holdings.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "chart.line.flattrend.xyaxis")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.white.opacity(0.6))
                                Text("No Holdings Yet")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Start trading to build your portfolio")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(holdings) { holding in
                                    HoldingCard(holding: holding)
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
                        
                        // Logout Button
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                Text("Logout")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            loadPortfolioData()
        }
    }
    
    private func loadPortfolioData() {
        guard let userId = auth.currentUser?.id else {
            errorMessage = "No user logged in"
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        // Load holdings
        db.collection("users").document(userId).collection("holdings")
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load holdings: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                self.holdings = documents.compactMap { doc in
                    try? doc.data(as: Holding.self)
                }
            }
        
        // Load portfolio statistics
        db.collection("users").document(userId).collection("portfolio")
            .document("statistics")
            .getDocument { snapshot, error in
                if let error = error {
                    print("Failed to load portfolio stats: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists {
                    self.portfolioStats = try? snapshot.data(as: PortfolioStatistics.self)
                }
            }
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
                .foregroundStyle(Color.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
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

struct HoldingCard: View {
    let holding: Holding
    
    var body: some View {
        HStack {
            // Symbol
            VStack(alignment: .leading, spacing: 4) {
                Text(holding.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("\(String(format: "%.2f", holding.quantity)) shares")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", holding.avgBuyPrice))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("avg. price")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.white.opacity(0.5))
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
