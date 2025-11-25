//
//  TabScreen.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-20.
//

import SwiftUI

struct TabScreen: View {
    @StateObject private var auth = AuthManager.shared
    @StateObject private var dmManager = DarkModeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                Group {
                    switch selectedTab {
                    case 0:
                        PortfolioView()
                    case 1:
                        StocksView()
                    case 2:
                        TransactionView()
                    case 3:
                        ProfileView()
                    default:
                        PortfolioView()
                    }
                }
            }
            
            // Custom bar (to support profile picture)
            CustomTabBar(selectedTab: $selectedTab, profilePicture: getProfilePicture())
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .onAppear {
            dmManager.syncWithUser()
        }
    }
    
    // Fetch user's profile picture
    private func getProfilePicture() -> UIImage? {
        if let pictureString = auth.currentUser?.picture,
           let imageData = Data(base64Encoded: pictureString),
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        return nil
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let profilePicture: UIImage?
    
    var body: some View {
        HStack {
            // Portfolio
            TabBarButton(
                icon: "briefcase.fill",
                title: "Portfolio",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            Spacer()
            
            // Browse
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Browse",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Spacer()
            
            // Transactions
            TabBarButton(
                icon: "list.bullet",
                title: "Transactions",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            Spacer()
            
            // Profile (w/ image)
            ProfileTabButton(
                profilePicture: profilePicture,
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.themeGradientStart, Color.themeGradientEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.95)
                Color.themeOverlay // glass effect
            }
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.themeBorderSecondary)
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : Color.themeSecondary)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white : Color.themeSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ProfileTabButton: View {
    let profilePicture: UIImage?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let profilePicture = profilePicture {
                    Image(uiImage: profilePicture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white : Color.themeSecondary, lineWidth: 2)
                        )
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? .white : Color.themeSecondary)
                }
                
                Text("Profile")
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white : Color.themeSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TabScreen()
}
