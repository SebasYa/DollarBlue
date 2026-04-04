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
import DollarNetworkManage

struct HomeView: View {
    @State private var dataController = DollarNetworkManager()
    @State private var alertMessage: AppAlertMessage?
    @State private var isLoading = false
    @State private var connectionStatus = QuoteConnectionStatus(
        state: .unknown,
        title: "Sin verificar",
        message: "Todavia no se consulto el estado de la API.",
        checkedAt: .now
    )
    @State private var showConnectionStatus = false
    @State private var isCheckingConnection = false

    @AppStorage("showPortraitHeader") private var showPortraitHeader = true
    @AppStorage("showUpdateStamp") private var showUpdateStamp = true
    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue
    @AppStorage("featuredMarketPrimary") private var featuredMarketPrimary = QuotePresentationSupport.defaultPrimaryMarketID
    @AppStorage("featuredMarketSecondary") private var featuredMarketSecondary = QuotePresentationSupport.defaultSecondaryMarketID

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                    headerSection

                    if !highlightedQuotes.isEmpty {
                        summarySection
                    }

                    if !dataController.cotizaciones.isEmpty {
                        marketPulseSection
                    }

                    quotesSection

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
            .refreshable {
                await reload()
            }
            .task {
                await reloadIfNeeded()
            }
        }
        .background(PremiumScreenBackground())
        .alert(item: $alertMessage) { errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage.value), dismissButton: .default(Text("OK")))
        }
    }

    private var headerSection: some View {
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
                        status: connectionStatus,
                        isChecking: isCheckingConnection
                    ) {
                        showConnectionStatus = true

                        Task {
                            await checkConnectionStatus()
                        }
                    }
                    .popover(isPresented: $showConnectionStatus, arrowEdge: .top) {
                        ConnectionStatusPopoverCard(status: connectionStatus)
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
                        label: "\(displayedQuotes.count) referencias"
                    )

                    if isLoading {
                        ProgressView()
                            .tint(PremiumPalette.emeraldHighlight)
                            .padding(.leading, 4)
                    }
                }
            
        }
    }

    private var marketPulseSection: some View {
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
                ForEach(marketPulseItems) { item in
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

    private var summarySection: some View {
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
                    MarketSummaryCard(dolarInfo: dolarInfo)
                }
            }
        }
    }

    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: useCompactCards ? 12 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Todas las referencias")
                        .font(.title3.weight(.semibold))
                    Text("Compra y venta ordenadas para una lectura rapida y mas financiera.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if isLoading && dataController.cotizaciones.isEmpty {
                LoadingStateCard(message: "Consultando mercado...")
            } else if dataController.cotizaciones.isEmpty {
                EmptyStateCard(
                    title: "Sin cotizaciones disponibles",
                    subtitle: "Desliza hacia abajo para volver a consultar el mercado."
                )
            } else {
                ForEach(displayedQuotes, id: \.nombre) { dolarInfo in
                    DollarRowView(dolarInfo: dolarInfo)
                }
            }
        }
    }

    private var highlightedQuotes: [DollarInfoModel] {
        QuotePresentationSupport.featuredQuotes(
            from: displayedQuotes,
            primaryMarketID: featuredMarketPrimary,
            secondaryMarketID: featuredMarketSecondary
        )
    }

    private var updateReference: String? {
        displayedQuotes.first?.fechaActualizacion
    }

    private var displayedQuotes: [DollarInfoModel] {
        QuotePresentationSupport.sortedQuotes(dataController.cotizaciones, order: selectedSortOrder)
    }

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    private var marketPulseItems: [MarketPulseItem] {
        [
            MarketPulseItem(
                label: "Compra promedio",
                value: premiumCurrencyString(averageBuy),
                detail: "Promedio de todas las referencias",
                icon: "arrow.down.left",
                accent: PremiumPalette.sand
            ),
            MarketPulseItem(
                label: "Venta promedio",
                value: premiumCurrencyString(averageSell),
                detail: "Promedio de salida del panel",
                icon: "arrow.up.right",
                accent: PremiumPalette.emerald
            ),
            MarketPulseItem(
                label: "Venta mas alta",
                value: premiumCurrencyString(highestSellValue),
                detail: highestSellQuote?.nombre ?? "Sin dato",
                icon: "chart.line.uptrend.xyaxis",
                accent: PremiumPalette.emeraldHighlight
            ),
            MarketPulseItem(
                label: "Spread promedio",
                value: premiumCurrencyString(averageSpread),
                detail: "Diferencia media entre compra y venta",
                icon: "arrow.left.and.right",
                accent: PremiumPalette.ink
            )
        ]
    }

    private var averageBuy: Double {
        guard !displayedQuotes.isEmpty else {
            return 0
        }

        let total = displayedQuotes.reduce(0) { $0 + $1.compra }
        return total / Double(displayedQuotes.count)
    }

    private var averageSell: Double {
        guard !displayedQuotes.isEmpty else {
            return 0
        }

        let total = displayedQuotes.reduce(0) { $0 + $1.venta }
        return total / Double(displayedQuotes.count)
    }

    private var highestSellQuote: DollarInfoModel? {
        displayedQuotes.max { lhs, rhs in
            lhs.venta < rhs.venta
        }
    }

    private var highestSellValue: Double {
        highestSellQuote?.venta ?? 0
    }

    private var averageSpread: Double {
        guard !displayedQuotes.isEmpty else {
            return 0
        }

        let total = displayedQuotes.reduce(0) { partial, quote in
            partial + max(0, quote.venta - quote.compra)
        }

        return total / Double(displayedQuotes.count)
    }

    private func reloadIfNeeded() async {
        guard dataController.cotizaciones.isEmpty else {
            return
        }

        await reload()
    }

    private func reload() async {
        isLoading = true
        connectionStatus = QuoteConnectionStatus(
            state: .checking,
            title: "Verificando conexion",
            message: "Consultando el estado actual de la API.",
            checkedAt: .now
        )
        alertMessage = await dataController.refreshFromServer()
        if let alertMessage {
            connectionStatus = QuoteConnectionStatus(
                state: .issue,
                title: "Problema con la API",
                message: alertMessage.value,
                checkedAt: .now
            )
        } else {
            connectionStatus = await DollarNetworkManager.fetchConnectionStatus()
        }
        isLoading = false
    }

    private func checkConnectionStatus() async {
        isCheckingConnection = true
        connectionStatus = QuoteConnectionStatus(
            state: .checking,
            title: "Verificando conexion",
            message: "Consultando el estado actual de la API.",
            checkedAt: .now
        )
        connectionStatus = await DollarNetworkManager.fetchConnectionStatus()
        isCheckingConnection = false
    }
}

private struct MarketPulseItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let detail: String
    let icon: String
    let accent: Color
}

private struct MarketSummaryCard: View {
    let dolarInfo: DollarInfoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dolarInfo.nombre.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.1)
                .foregroundStyle(PremiumPalette.emerald)

            VStack(alignment: .leading, spacing: 6) {
                Label("Compra", systemImage: "arrow.down.left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PremiumCurrencyValueText(
                    value: dolarInfo.compra,
                    accent: .primary,
                    integerSize: 24,
                    centsSize: 15
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Label("Venta", systemImage: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PremiumCurrencyValueText(
                    value: dolarInfo.venta,
                    accent: PremiumPalette.emeraldHighlight,
                    integerSize: 20,
                    centsSize: 14
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 26, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

private struct HomeHeroArt: View {
    let status: QuoteConnectionStatus
    let isChecking: Bool
    let action: () -> Void

    private var statusColor: Color {
        switch status.state {
        case .stable:
            return PremiumPalette.emeraldHighlight
        case .checking:
            return PremiumPalette.sand
        case .issue:
            return .red
        case .unknown:
            return .gray
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: -18) {
                    Image("ImageFranklin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 64)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)

                    Image("ImageRoca")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: 54, height: 66)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                }

                Circle()
                    .fill(statusColor)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    }
                    .overlay {
                        if isChecking {
                            ProgressView()
                                .scaleEffect(0.45)
                                .tint(.white)
                        }
                    }
                    .offset(x: 2, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .premiumSurface(cornerRadius: 26, accent: PremiumPalette.emerald, glassEnabled: true)
        }
        .buttonStyle(.plain)
    }
}

private struct ConnectionStatusPopoverCard: View {
    let status: QuoteConnectionStatus

    private var accent: Color {
        switch status.state {
        case .stable:
            return PremiumPalette.emeraldHighlight
        case .checking:
            return PremiumPalette.sand
        case .issue:
            return .red
        case .unknown:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(accent)
                    .frame(width: 12, height: 12)

                Text(status.title)
                    .font(.headline)
            }

            Text(status.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Chequeado a las \(premiumFormattedCheckTime(status.checkedAt))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 260, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: accent, glassEnabled: true)
    }
}

private struct LoadingStateCard: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(PremiumPalette.emeraldHighlight)
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

private struct EmptyStateCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.sand, glassEnabled: true)
    }
}

#Preview {
    HomeView()
}
