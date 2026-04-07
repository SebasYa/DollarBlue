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
    @State private var pulseItems = [HomeMarketPulseItem]()
    @State private var historicalStore = HistoricalDollarStore()
    @State private var historicalComparisonsByName = [String: QuoteHistoricalComparison]()

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
                        HomeSummarySection(
                            highlightedQuotes: presentation.highlightedQuotes,
                            historicalComparisonsByName: historicalComparisonsByName
                        )
                            .equatable()
                    }

                    if !presentation.displayedQuotes.isEmpty {
                        HomeMarketPulseSection(items: pulseItems)
                            .equatable()
                    }

                    HomeQuotesSection(
                        displayedQuotes: presentation.displayedQuotes,
                        isLoading: quoteStore.isLoading,
                        useCompactCards: useCompactCards,
                        showUpdateStamp: showUpdateStamp,
                        historicalComparisonsByName: historicalComparisonsByName
                    )
                    .equatable()

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, PremiumLayout.screenHorizontalPadding)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
            .refreshable {
                await quoteStore.refresh()
            }
        }
        .task(id: presentationDependencies) {
            let nextPresentation = QuotePresentationSupport.homePresentation(
                quotes: quoteStore.quotes,
                order: selectedSortOrder,
                primaryMarketID: featuredMarketPrimary,
                secondaryMarketID: featuredMarketSecondary
            )

            presentation = nextPresentation

            let cachedComparisonsByName = QuotePresentationSupport.historicalComparisonsByQuoteName(
                displayedQuotes: nextPresentation.displayedQuotes,
                currentQuotes: quoteStore.dollarQuotes,
                comparisonsByHouse: historicalStore.comparisonsByHouse
            )

            historicalComparisonsByName = cachedComparisonsByName
            pulseItems = homeMarketPulseItems(
                highlightedQuotes: nextPresentation.highlightedQuotes,
                historicalComparisonsByName: cachedComparisonsByName
            )

            let houses = QuotePresentationSupport.resolvedHouses(
                for: nextPresentation.displayedQuotes,
                currentQuotes: quoteStore.dollarQuotes
            )

            await historicalStore.loadComparisonsIfNeeded(
                using: quoteStore.dollarQuotes,
                houses: houses
            )

            let comparisonsByName = QuotePresentationSupport.historicalComparisonsByQuoteName(
                displayedQuotes: nextPresentation.displayedQuotes,
                currentQuotes: quoteStore.dollarQuotes,
                comparisonsByHouse: historicalStore.comparisonsByHouse
            )

            historicalComparisonsByName = comparisonsByName
            pulseItems = homeMarketPulseItems(
                highlightedQuotes: nextPresentation.highlightedQuotes,
                historicalComparisonsByName: comparisonsByName
            )
        }
    }

    private func homeMarketPulseItems(
        highlightedQuotes: [DollarInfoModel],
        historicalComparisonsByName: [String: QuoteHistoricalComparison]
    ) -> [HomeMarketPulseItem] {
        highlightedQuotes.flatMap { quote in
            let title = QuotePresentationSupport.compactDisplayName(for: quote.nombre)
            let comparison = historicalComparisonsByName[quote.nombre]

            return [
                HomeMarketPulseItem(
                    id: "\(quote.nombre)-buy",
                    label: "\(title) compra",
                    value: historicalDifferenceText(for: comparison?.buy),
                    detail: historicalDetailText(for: comparison?.buy),
                    icon: historicalIcon(for: comparison?.buy),
                    accent: historicalAccent(for: comparison?.buy)
                ),
                HomeMarketPulseItem(
                    id: "\(quote.nombre)-sell",
                    label: "\(title) venta",
                    value: historicalDifferenceText(for: comparison?.sell),
                    detail: historicalDetailText(for: comparison?.sell),
                    icon: historicalIcon(for: comparison?.sell),
                    accent: historicalAccent(for: comparison?.sell)
                )
            ]
        }
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

private extension HomeView {
    func historicalDifferenceText(for change: HistoricalValueChange?) -> String {
        guard let change, let difference = change.difference else {
            return "Sin dato"
        }

        if abs(difference) < 0.0001 {
            return premiumCurrencyString(0)
        }

        let prefix = difference > 0 ? "+" : "-"
        return "\(prefix)\(premiumCurrencyString(abs(difference)))"
    }

    func historicalDetailText(for change: HistoricalValueChange?) -> String {
        guard
            let change,
            let previousValue = change.previousValue
        else {
            return "Sin histórico disponible"
        }

        return "Ayer \(premiumCurrencyString(previousValue))"
    }

    func historicalIcon(for change: HistoricalValueChange?) -> String {
        guard let change else {
            return "clock.badge.questionmark"
        }

        switch change.trend {
        case .up:
            return "arrow.up.right"
        case .down:
            return "arrow.down.right"
        case .flat:
            return "arrow.right"
        case .unavailable:
            return "clock.badge.questionmark"
        }
    }

    func historicalAccent(for change: HistoricalValueChange?) -> Color {
        guard let change else {
            return PremiumPalette.sand
        }

        switch change.trend {
        case .up:
            return PremiumPalette.emeraldHighlight
        case .down:
            return .red
        case .flat:
            return PremiumPalette.sand
        case .unavailable:
            return PremiumPalette.sand
        }
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
