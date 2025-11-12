//
//  RegisterView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import SwiftUI

struct RegisterView: View {
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject var auth = AuthManager.shared
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 25) {
                    // Header with Logo
                    VStack(spacing: 8) {
                        // Can change to an image in the future
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 90, height: 90)
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.white)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Text("Join TradeLabs - Start your trading journey today!")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Form container
                    VStack(spacing: 20) {
                        CustomTextField(
                            icon: "person.fill",
                            placeholder: "Username",
                            text: $displayName
                        )
                        
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email
                        )
                        
                        CustomSecureField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password
                        )
                        
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
                        
                        Button(action: handleRegistration) {
                            Text("Register")
                                .font(.headline)
                                .foregroundStyle(.white)
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
                        
                        HStack {
                            Text("Already have an account?")
                                .foregroundStyle(Color.white.opacity(0.8))
                            NavigationLink(destination: LoginView()) {
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .font(.subheadline)
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
    }
    
    private func handleRegistration() {
        // Validate email
        guard Validators.checkEmail(email) else {
            self.errorMessage = "Please enter a valid email address."
            return
        }
        
        // Validate password
        guard Validators.isValidPassword(password) else {
            self.errorMessage = "Password must be at least 6 characters."
            return
        }
        
        // Display name
        guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.errorMessage = "Please enter a display name."
            return
        }
        
        auth.signUp(email: email, password: password, displayName: displayName) { result in
            switch result {
            case .success:
                self.errorMessage = nil
            case .failure(let failure):
                self.errorMessage = failure.localizedDescription
            }
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.white.opacity(0.7))
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .foregroundStyle(Color.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.white.opacity(0.7))
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .foregroundStyle(Color.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        RegisterView()
    }
}
