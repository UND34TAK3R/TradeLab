//
//  TradeLabApp.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-28.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()

    return true
  }
}

@main
struct TradeLabApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthManager.shared
    @StateObject var webSocketsManager = WebSocketsManager.shared
    @StateObject var transactionManager = TransactionsManager.shared
    @StateObject var holdingsManager = HoldingsManager.shared
    @StateObject var darkModeManager = DarkModeManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(webSocketsManager)
                .environmentObject(transactionManager)
                .environmentObject(holdingsManager)
                .environmentObject(darkModeManager)
                .preferredColorScheme(darkModeManager.isDarkMode ? .dark : .light)
                .onAppear {
                    webSocketsManager.startCollectingTrades()
            }
        }
    }
}
