//
//  TabScreen.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-20.
//

import SwiftUI

struct TabScreen: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        TabView {
            PortfolioView()
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text("Portfolio")
                }
            StocksView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Browse")
                }
            TransactionView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle") // change to icon ?
                    Text("Profile")
                }
        }
        .accentColor(.indigo)
        .background(Color.clear)
    }
}

#Preview {
    TabScreen()
}
