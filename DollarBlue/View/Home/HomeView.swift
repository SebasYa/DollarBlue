//
//  HomeView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct HomeView: View {
    @Environment(QuoteStore.self) private var quoteStore

    @State private var showConnectionStatus = false

    @AppStorage("showPortraitHeader") private var showPortraitHeader = true
    @AppStorage("showUpdateStamp") private var showUpdateStamp = true
    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue
    @AppStorage("featuredMarketPrimary") private var featuredMarketPrimary = QuotePresentationSupport.defaultPrimaryMarketID
    @AppStorage("featuredMarketSecondary") private var featuredMarketSecondary = QuotePresentationSupport.defaultSecondaryMarketID

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    var body: some View {
        let displayedQuotes = QuotePresentationSupport.sortedQuotes(quoteStore.quotes, order: selectedSortOrder)
        let highlightedQuotes = QuotePresentationSupport.featuredQuotes(
            from: displayedQuotes,
            primaryMarketID: featuredMarketPrimary,
            secondaryMarketID: featuredMarketSecondary
        )
        let updateReference = displayedQuotes.first?.fechaActualizacion
        let dashboardMetrics = QuotePresentationSupport.dashboardMetrics(from: displayedQuotes)
        let pulseItems = homeMarketPulseItems(using: dashboardMetrics)

        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                    HomeHeaderSection(
                        showPortraitHeader: showPortraitHeader,
                        status: quoteStore.connectionStatus,
                        isLoading: quoteStore.isLoading,
                        showUpdateStamp: showUpdateStamp,
                        updateReference: updateReference,
                        displayedQuotesCount: displayedQuotes.count,
                        showConnectionStatus: $showConnectionStatus
                    )

                    if !highlightedQuotes.isEmpty {
                        HomeSummarySection(highlightedQuotes: highlightedQuotes)
                    }

                    if !displayedQuotes.isEmpty {
                        HomeMarketPulseSection(items: pulseItems)
                    }

                    HomeQuotesSection(
                        displayedQuotes: displayedQuotes,
                        isLoading: quoteStore.isLoading,
                        useCompactCards: useCompactCards,
                        showUpdateStamp: showUpdateStamp
                    )

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
            .refreshable {
                await quoteStore.refresh()
            }
        }
    }

    private func homeMarketPulseItems(using metrics: QuoteDashboardMetrics) -> [HomeMarketPulseItem] {
        [
            HomeMarketPulseItem(
                id: "average-buy",
                label: "Compra promedio",
                value: premiumCurrencyString(metrics.averageBuy),
                detail: "Promedio de todas las referencias",
                icon: "arrow.down.left",
                accent: PremiumPalette.sand
            ),
            HomeMarketPulseItem(
                id: "average-sell",
                label: "Venta promedio",
                value: premiumCurrencyString(metrics.averageSell),
                detail: "Promedio de salida del panel",
                icon: "arrow.up.right",
                accent: PremiumPalette.emerald
            ),
            HomeMarketPulseItem(
                id: "highest-sell",
                label: "Venta mas alta",
                value: premiumCurrencyString(metrics.highestSellValue),
                detail: metrics.highestSellQuote?.nombre ?? "Sin dato",
                icon: "chart.line.uptrend.xyaxis",
                accent: PremiumPalette.emeraldHighlight
            ),
            HomeMarketPulseItem(
                id: "average-spread",
                label: "Spread promedio",
                value: premiumCurrencyString(metrics.averageSpread),
                detail: "Diferencia media entre compra y venta",
                icon: "arrow.left.and.right",
                accent: PremiumPalette.ink
            )
        ]
    }
}

#Preview {
    HomeView()
        .environment(QuoteStore())
}
