//
//  ProfileView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-12.
//

// TODO:
//      - Test UI
//      - Ensure it fetches properly from collection

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @StateObject var auth = AuthManager.shared
    @StateObject var dmManager = DarkModeManager.shared
    @State private var appUser: AppUser?
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
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.themePrimary)
                            .padding(.top, 100)
                    } else if let appUser = appUser {
                        // Profile Header
                        VStack(spacing: 15) {
                            // Profile Picture
                            ZStack {
                                Circle()
                                    .fill(Color.themeOverlay)
                                    .frame(width: 120, height: 120)
                                
                                if let pictureURL = appUser.picture, !pictureURL.isEmpty {
                                    AsyncImage(url: URL(string: pictureURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundStyle(Color.themePrimary)
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundStyle(Color.themePrimary)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // Display Name
                            Text(appUser.displayName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.themePrimary)
                            
                            // Email
                            Text(appUser.email)
                                .font(.subheadline)
                                .foregroundStyle(Color.themeSecondary)
                            
                            // Active Status Badge
                            HStack {
                                Circle()
                                    .fill(appUser.isActive ? Color.green : Color.gray)
                                    .frame(width: 10, height: 10)
                                Text(appUser.isActive ? "Active" : "Inactive")
                                    .font(.caption)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.themeOverlay)
                            .cornerRadius(20)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        // Profile Information Card
                        VStack(spacing: 20) {
                            ProfileInfoRow(
                                icon: "envelope.fill",
                                label: "Email",
                                value: appUser.email
                            )
                            
                            Divider()
                                .background(Color.themeBorderSecondary)
                            
                            ProfileInfoRow(
                                icon: "person.fill",
                                label: "Display Name",
                                value: appUser.displayName
                            )
                            
                            Divider()
                                .background(Color.themeBorderSecondary)
                            
                            ProfileInfoRow(
                                icon: "creditcard.fill",
                                label: "Balance",
                                value: "\(String(format: "%.2f", appUser.wallet))$"
                            )
                            
                            Divider()
                                .background(Color.themeBorderSecondary)
                            
                            ProfileInfoRow(
                                icon: "moon.fill",
                                label: "Dark Mode",
                                value: appUser.isDarkMode ? "Enabled" : "Disabled"
                            )
                            
                            Divider()
                                .background(Color.themeBorderSecondary)
                            
                            ProfileInfoRow(
                                icon: "checkmark.circle.fill",
                                label: "Account Status",
                                value: appUser.isActive ? "Active" : "Inactive"
                            )
                            
                            // Edit Profile Button
                            NavigationLink(destination: EditProfileView()) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .padding(.top, 10)
                            
                            // Logout Button
                            Button(action: handleLogout) {
                                HStack {
                                    Image(systemName: "arrow.right.square.fill")
                                    Text("Logout")
                                }
                                .font(.headline)
                                .foregroundStyle(Color.themePrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(dmManager.isDarkMode ? .dark : .light)
        .onAppear {
            dmManager.syncWithUser()
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        // Check if we already have the current user from AuthManager
        if let currentUser = auth.currentUser {
            self.appUser = currentUser
            isLoading = false
        } else {
            // Fetch from Firestore if not available
            auth.fetchCurrentAppUser { result in
                isLoading = false
                switch result {
                case .success(let user):
                    if let user = user {
                        self.appUser = user
                    } else {
                        self.errorMessage = "No user logged in"
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                }
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

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.themeSecondary)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.themeSecondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(Color.themePrimary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
