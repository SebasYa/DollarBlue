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
    @State private var presentation = HomeQuotePresentation.empty

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
        let pulseItems = homeMarketPulseItems(using: presentation.dashboardMetrics)

        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                    HomeHeaderSection(
                        showPortraitHeader: showPortraitHeader,
                        status: quoteStore.connectionStatus,
                        isLoading: quoteStore.isLoading,
                        showUpdateStamp: showUpdateStamp,
                        updateReference: presentation.updateReference,
                        displayedQuotesCount: presentation.displayedQuotes.count,
                        showConnectionStatus: $showConnectionStatus
                    )

                    if !presentation.highlightedQuotes.isEmpty {
                        HomeSummarySection(highlightedQuotes: presentation.highlightedQuotes)
                    }

                    if !presentation.displayedQuotes.isEmpty {
                        HomeMarketPulseSection(items: pulseItems)
                    }

                    HomeQuotesSection(
                        displayedQuotes: presentation.displayedQuotes,
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
        .task(id: presentationDependencies) {
            presentation = QuotePresentationSupport.homePresentation(
                quotes: quoteStore.quotes,
                order: selectedSortOrder,
                primaryMarketID: featuredMarketPrimary,
                secondaryMarketID: featuredMarketSecondary
            )
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

    private var presentationDependencies: HomePresentationDependencies {
        HomePresentationDependencies(
            refreshRevision: quoteStore.refreshRevision,
            quotesCount: quoteStore.quotes.count,
            sortOrder: selectedSortOrder,
            primaryMarketID: featuredMarketPrimary,
            secondaryMarketID: featuredMarketSecondary
        )
    }
}

private struct HomePresentationDependencies: Hashable {
    let refreshRevision: Int
    let quotesCount: Int
    let sortOrder: QuoteSortOrder
    let primaryMarketID: String
    let secondaryMarketID: String
}

#Preview {
    HomeView()
        .environment(QuoteStore())
}
