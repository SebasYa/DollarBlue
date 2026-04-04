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
    @State private var activeTab: TabModel = .home
    @AppStorage("themePreference") private var themePreference = AppThemeMode.system.rawValue
    @State private var tabBarFrame: CGRect = .zero
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Group {
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
                    
                    .preferredColorScheme(selectedTheme.colorScheme)
                }
                CustomTabBarView(activeTab: $activeTab)
            }
            .coordinateSpace(name: FloatingTabBarLayout.coordinateSpaceName)
            .environment(\.floatingTabBarInset, resolvedFloatingTabBarInset(in: proxy))
            .onPreferenceChange(FloatingTabBarFramePreferenceKey.self) { newValue in
                tabBarFrame = newValue
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func resolvedFloatingTabBarInset(in proxy: GeometryProxy) -> CGFloat {
        guard tabBarFrame != .zero else {
            return 0
        }

        let safeBottom = proxy.size.height - proxy.safeAreaInsets.bottom
        return max(0, safeBottom - tabBarFrame.minY)
    }

    private var selectedTheme: AppThemeMode {
        AppThemeMode(rawValue: themePreference) ?? .system
    }
}

#Preview {
    ContentView()
}
