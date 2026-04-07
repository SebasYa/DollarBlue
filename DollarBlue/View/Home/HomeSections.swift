//
//  HomeSections.swift
//  DollarBlue
//
//  Created by Codex on 05/04/2026.
//

import SwiftUI
import DollarInfoModel

struct HomeHeaderSection: View {
    let showPortraitHeader: Bool
    let status: QuoteConnectionStatus
    let isLoading: Bool
    let showUpdateStamp: Bool
    let updateReference: String?
    let displayedQuotesCount: Int
    @Binding var showConnectionStatus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                PremiumSectionHeader(
                    eyebrow: "Mercado argentino",
                    title: "Dolar",
                    subtitle: "Una lectura sobria, clara y actual de cada cotización."
                )

                Spacer(minLength: 12)

                if showPortraitHeader {
                    HomeHeroArt(
                        status: status,
                        isChecking: isLoading
                    ) {
                        showConnectionStatus = true
                    }
                    .popover(isPresented: $showConnectionStatus, arrowEdge: .top) {
                        ConnectionStatusPopoverCard(status: status)
                            .presentationCompactAdaptation(.popover)
                    }
                }
            }

            HStack(spacing: 10) {
                if showUpdateStamp, let updateReference {
                    PremiumPill(
                        icon: "clock.arrow.circlepath",
                        label: "Actualizado \(premiumCompactUpdateString(updateReference))"
                    )
                }

                PremiumPill(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "\(displayedQuotesCount) referencias"
                )

                if isLoading {
                    ProgressView()
                        .tint(PremiumPalette.emeraldHighlight)
                        .padding(.leading, 4)
                }
            }
        }
    }
}

struct HomeMarketPulseSection: View, Equatable {
    let items: [HomeMarketPulseItem]

    static func == (lhs: HomeMarketPulseSection, rhs: HomeMarketPulseSection) -> Bool {
        lhs.items == rhs.items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pulso del mercado")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(items) { item in
                    PremiumMetricTile(
                        label: item.label,
                        value: item.value,
                        detail: item.detail,
                        icon: item.icon,
                        accent: item.accent,
                        glassEnabled: true
                    )
                }
            }
        }
    }
}

struct HomeSummarySection: View, Equatable {
    let highlightedQuotes: [DollarInfoModel]
    let historicalComparisonsByName: [String: QuoteHistoricalComparison]

    static func == (lhs: HomeSummarySection, rhs: HomeSummarySection) -> Bool {
        lhs.highlightedQuotes.count == rhs.highlightedQuotes.count &&
        zip(lhs.highlightedQuotes, rhs.highlightedQuotes).allSatisfy { lhsQuote, rhsQuote in
            lhsQuote.nombre == rhsQuote.nombre &&
            lhsQuote.compra == rhsQuote.compra &&
            lhsQuote.venta == rhsQuote.venta
        } &&
        lhs.historicalComparisonsByName == rhs.historicalComparisonsByName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mercados destacados")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(highlightedQuotes, id: \.nombre) { dolarInfo in
                    MarketSummaryCard(
                        dolarInfo: dolarInfo,
                        historicalComparison: historicalComparisonsByName[dolarInfo.nombre]
                    )
                }
            }
        }
    }
}

struct HomeQuotesSection: View, Equatable {
    let displayedQuotes: [DollarInfoModel]
    let isLoading: Bool
    let useCompactCards: Bool
    let showUpdateStamp: Bool
    let historicalComparisonsByName: [String: QuoteHistoricalComparison]

    static func == (lhs: HomeQuotesSection, rhs: HomeQuotesSection) -> Bool {
        lhs.displayedQuotes.count == rhs.displayedQuotes.count &&
        zip(lhs.displayedQuotes, rhs.displayedQuotes).allSatisfy { lhsQuote, rhsQuote in
            lhsQuote.nombre == rhsQuote.nombre &&
            lhsQuote.compra == rhsQuote.compra &&
            lhsQuote.venta == rhsQuote.venta &&
            lhsQuote.fechaActualizacion == rhsQuote.fechaActualizacion
        } &&
        lhs.isLoading == rhs.isLoading &&
        lhs.useCompactCards == rhs.useCompactCards &&
        lhs.showUpdateStamp == rhs.showUpdateStamp &&
        lhs.historicalComparisonsByName == rhs.historicalComparisonsByName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: useCompactCards ? 12 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Todas las referencias")
                        .font(.title3.weight(.semibold))
                    Text("Compra y venta ordenadas para una lectura rápida y mas financiera.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if isLoading && displayedQuotes.isEmpty {
                HomeLoadingStateCard(message: "Consultando mercado...")
            } else if displayedQuotes.isEmpty {
                HomeEmptyStateCard(
                    title: "Sin cotizaciones disponibles",
                    subtitle: "Desliza hacia abajo para volver a consultar el mercado."
                )
            } else {
                LazyVStack(spacing: useCompactCards ? 12 : 16) {
                    ForEach(displayedQuotes, id: \.nombre) { dolarInfo in
                        DollarRowView(
                            dolarInfo: dolarInfo,
                            useCompactCards: useCompactCards,
                            showUpdateStamp: showUpdateStamp,
                            historicalComparison: historicalComparisonsByName[dolarInfo.nombre]
                        )
                        .equatable()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showConnectionStatus = false
    HomeHeaderSection(
        showPortraitHeader: true,
        status: .stable(quotesCount: 6),
        isLoading: false,
        showUpdateStamp: true,
        updateReference: "2026-05-04T12:00:00Z",
        displayedQuotesCount: 6,
        showConnectionStatus: $showConnectionStatus
    ).padding(14)
}
