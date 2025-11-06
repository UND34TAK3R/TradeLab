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
        VStack {
            TextField("Username", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.title3)
            }
            
            Button("Register"){
                print("SignUp clicked")
                //validation
                guard Validators.checkEmail(email) else{
                    self.errorMessage = "Invalid email"
                    return
                }
                guard Validators.isValidPassword(password) else{
                    self.errorMessage = "Password must be at least 6 characters"
                    return
                }
                guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else{
                    self.errorMessage = "Display name is required"
                    return
                }
                auth.signUp(email: email, password: password, displayName: displayName) { result in
                    switch result {
                    case.success(let success):
                        self.errorMessage = nil
                    case .failure(let failure):
                        self.errorMessage = failure.localizedDescription
                    }
                }
            }
            NavigationLink(destination: LoginView()){
                Text("Login ? Click here")
            }
        }.padding()
    }
}

#Preview {
    RegisterView()
}
