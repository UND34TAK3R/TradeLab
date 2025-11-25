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
    @State private var profileImage: UIImage?
    
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
                                
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
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
        .refreshable {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        isLoading = true
        
        auth.fetchCurrentAppUser { result in
            isLoading = false
            switch result {
            case .success(let user):
                if let user = user {
                    self.appUser = user
                    self.loadProfileImage(from: user.picture)
                } else {
                    self.errorMessage = "Failed to fetch user data"
                }
            case .failure(let error):
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadProfileImage(from base64String: String?) {
            //print("Attempting to load profile image...")
            
            guard let base64String = base64String else {
                //print("No base64 string provided")
                self.profileImage = nil
                return
            }
            
            guard !base64String.isEmpty else {
                //print("Base64 string is empty")
                self.profileImage = nil
                return
            }
            
            guard let imageData = Data(base64Encoded: base64String) else {
                //print("Failed to decode base64 string to Data")
                self.profileImage = nil
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                //print("Failed to create UIImage from data")
                self.profileImage = nil
                return
            }
            
            //print("✅ Profile image loaded successfully!")
            self.profileImage = image
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
