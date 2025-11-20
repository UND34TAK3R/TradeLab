//
//  ContentView.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthManager.shared
    @StateObject private var socket = WebSocketsManager.shared
    @State private var isLoaded = false
    var body: some View {
        NavigationView{
            if auth.currentUser != nil {
                TabScreen()
            }
            else{
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(WebSocketsManager())
}
