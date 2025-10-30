//
//  RegisterView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authManager: AuthManager
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
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
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Please fill in all fields"
                    return
                }
                if password.count < 6 {
                    errorMessage = "Password must have at least 6 characters"
                    return
                }
                authManager.register(email: email, password: password) { result in
                    switch result{
                    case .success:
                        print("Registeration Successful")
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
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
