//
//  LoginView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import SwiftUI

struct LoginView: View {
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
            
            Button("Login"){
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Please fill in all fields"
                    return
                }
                authManager.login(email: email, password: password) { result in
                    switch result{
                    case .success:
                        print("Login Successful")
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
            NavigationLink(destination: RegisterView()){
                Text("Register ? Click here")
            }
        }.padding()    }
}

#Preview {
    LoginView()
}
