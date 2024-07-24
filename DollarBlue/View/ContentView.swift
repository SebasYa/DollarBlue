//
//  ContentView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct ContentView: View {
    @State private var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode")
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            CalculationView()
                .tabItem {
                    Label("Calculator", systemImage: "brain.fill")
                }
            ConfigView(isDarkMode: $isDarkMode)
                .tabItem {
                    Label("Configuration", systemImage: "gear")
                }
        }
        .tint(Color("ColorGreenD"))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: isDarkMode) { oldValue, newValue in
            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
        }
    }
}

#Preview {
    ContentView()
}
