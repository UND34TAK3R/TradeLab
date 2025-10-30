//
//  PortfolioView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import SwiftUI
import FirebaseAuth

struct PortfolioView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        VStack{
            Text("Welcome, \(authManager.user?.email ?? "Unknown user")!")
                .font(.title)
                .padding()
            Button{
                authManager.logout()
            } label: {
                Text("Logout")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.red)
                    .cornerRadius(10)
            }.padding()
        }
    }
}

#Preview {
    PortfolioView()
}
