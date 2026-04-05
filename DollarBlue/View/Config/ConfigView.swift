//
//  ConfigView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct ConfigView: View {
    @AppStorage("themePreference") private var themePreference = AppThemeMode.system.rawValue
    @AppStorage("showPortraitHeader") private var showPortraitHeader = true
    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("showUpdateStamp") private var showUpdateStamp = true
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue
    @AppStorage("featuredMarketPrimary") private var featuredMarketPrimary = QuotePresentationSupport.defaultPrimaryMarketID
    @AppStorage("featuredMarketSecondary") private var featuredMarketSecondary = QuotePresentationSupport.defaultSecondaryMarketID

    private var selectedTheme: AppThemeMode {
        AppThemeMode(rawValue: themePreference) ?? .system
    }

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 18) {
                    PremiumSectionHeader(
                        eyebrow: "Personalizacion",
                        title: "Ajustes",
                        subtitle: "Una mezcla entre lectura financiera sobria y una capa visual mas nativa para iOS."
                    )

                    ConfigThemeSection(
                        selectedTheme: selectedTheme,
                        selectTheme: selectTheme
                    )

                    ConfigExperienceSection(
                        showPortraitHeader: $showPortraitHeader,
                        useCompactCards: $useCompactCards,
                        showUpdateStamp: $showUpdateStamp
                    )

                    ConfigMarketConfigurationSection(
                        selectedSortOrder: selectedSortOrder,
                        featuredMarketPrimary: featuredMarketPrimary,
                        featuredMarketSecondary: featuredMarketSecondary,
                        selectSortOrder: selectSortOrder,
                        selectPrimaryMarket: updatePrimaryMarket,
                        selectSecondaryMarket: updateSecondaryMarket
                    )

                    ConfigPreviewSection(
                        selectedTheme: selectedTheme,
                        useCompactCards: useCompactCards,
                        showUpdateStamp: showUpdateStamp,
                        featuredMarketPrimary: featuredMarketPrimary,
                        featuredMarketSecondary: featuredMarketSecondary,
                        selectedSortOrder: selectedSortOrder
                    )

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
        }
    }

    private func selectTheme(_ mode: AppThemeMode) {
        themePreference = mode.rawValue
    }

    private func selectSortOrder(_ order: QuoteSortOrder) {
        quoteSortOrder = order.rawValue
    }

    private func updatePrimaryMarket(_ newMarketID: String) {
        let previousPrimary = featuredMarketPrimary
        featuredMarketPrimary = newMarketID

        if featuredMarketSecondary == newMarketID {
            featuredMarketSecondary = previousPrimary
        }
    }

    private func updateSecondaryMarket(_ newMarketID: String) {
        let previousSecondary = featuredMarketSecondary
        featuredMarketSecondary = newMarketID

        if featuredMarketPrimary == newMarketID {
            featuredMarketPrimary = previousSecondary
        }
    }
}

#Preview {
    ConfigView()
}
