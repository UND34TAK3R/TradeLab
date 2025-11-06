//
//  PortfolioView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import SwiftUI
import FirebaseAuth

struct PortfolioView: View {
    @StateObject var auth = AuthManager.shared
    var body: some View {
        VStack{
            Text("Welcome, \(auth.currentUser?.displayName ?? "Uknown User") !")
                .font(.title)
                .padding()
            Button(role: .destructive){
                let result = auth.signOut()
    
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
