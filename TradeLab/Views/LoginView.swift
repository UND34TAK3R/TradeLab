//
//  LoginView.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-10-29.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject var auth = AuthManager.shared
    @State private var errorMessage: String?
    
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
                    VStack(spacing: 8) {
                        // Can change to an image in the future
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 90, height: 90)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.white)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
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
                        
                        Button(action: handleLogin) {
                            Text("Login")
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
                            Text("Don't have an account?")
                                .foregroundStyle(Color.white.opacity(0.8))
                            NavigationLink(destination: RegisterView()) {
                                Text("Register")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .font(.subheadline)
                        
                        NavigationLink(destination: ResetPasswordView()) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.9))
                                .underline()
                        }
                        .padding(.top, 5)
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
    
    private func handleLogin() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            return
        }
        
        auth.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("Login Successful")
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
