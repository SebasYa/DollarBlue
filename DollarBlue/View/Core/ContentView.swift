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
    @Environment(QuoteStore.self) private var quoteStore
    @State private var activeTab: TabModel = .home
    @State private var isTabBarHidden = false
    @AppStorage("themePreference") private var themePreference = AppThemeMode.system.rawValue
    @State private var floatingTabBarInset: CGFloat = 0
    
    var body: some View {
        @Bindable var quoteStore = quoteStore

        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                PremiumScreenBackground()

                TabView(selection: $activeTab) {
                    
                    Tab.init(value: .home) {
                        HomeView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    
                    Tab.init(value: .calculator) {
                        CalculationView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    
                    Tab.init(value: .configuration) {
                        ConfigView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                        
                    }
                }
                CustomTabBarView(activeTab: $activeTab)
                    .opacity(isTabBarHidden ? 0 : 1)
                    .offset(y: isTabBarHidden ? 120 : 0)
                    .allowsHitTesting(!isTabBarHidden)
                    .background {
                        GeometryReader { tabBarProxy in
                            Color.clear
                                .preference(
                                    key: FloatingTabBarInsetPreferenceKey.self,
                                    value: isTabBarHidden
                                        ? 0
                                        : max(
                                            0,
                                            proxy.size.height - tabBarProxy.frame(in: .named(FloatingTabBarLayout.coordinateSpaceName)).minY
                                        )
                                )
                        }
                    }
            }
            .coordinateSpace(name: FloatingTabBarLayout.coordinateSpaceName)
            .environment(\.floatingTabBarInset, floatingTabBarInset)
            .onPreferenceChange(FloatingTabBarInsetPreferenceKey.self) { newValue in
                floatingTabBarInset = newValue
            }
            .onPreferenceChange(CustomTabBarHiddenPreferenceKey.self) { newValue in
                isTabBarHidden = newValue
            }
            .preferredColorScheme(selectedTheme.colorScheme)
        }
        .task {
            await quoteStore.loadIfNeeded()
        }
        .alert(item: $quoteStore.alertMessage) { errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage.value), dismissButton: .default(Text("OK")) {
                quoteStore.dismissAlert()
            })
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var selectedTheme: AppThemeMode {
        AppThemeMode(rawValue: themePreference) ?? .system
    }
}

#Preview {
    ContentView()
        .environment(QuoteStore())
}
