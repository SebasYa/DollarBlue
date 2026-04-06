//
//  ContentView.swift
//  DollarBlueW Watch App
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct ContentView: View {
    @State private var quoteStore = QuoteStore()

    var body: some View {
        @Bindable var quoteStore = quoteStore

        NavigationStack {
            ZStack {
                PremiumScreenBackground()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        watchHeader

                        if !quoteStore.quotes.isEmpty {
                            watchOverview
                        }

                        if quoteStore.isLoading && quoteStore.quotes.isEmpty {
                            ProgressView("Consultando...")
                                .tint(PremiumPalette.emeraldHighlight)
                                .font(.caption2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if quoteStore.quotes.isEmpty {
                            Text("Sin cotizaciones por ahora.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .premiumSurface(cornerRadius: 18, accent: PremiumPalette.sand, glassEnabled: false)
                        } else {
                            ForEach(quoteStore.quotes, id: \.nombre) { dolarInfo in
                                DollarRowView(dolarInfo: dolarInfo)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Mercado")
        }
        .task {
            await quoteStore.loadIfNeeded()
        }
        .alert(item: $quoteStore.alertMessage) { errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage.value), dismissButton: .default(Text("OK")) {
                quoteStore.dismissAlert()
            })
        }
    }

    private var watchHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Mesa del dolar")
                .font(.system(.headline, design: .serif).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text("Mercado argentino en vivo")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            if let updateReference {
                Text("Act. \(premiumCompactMiniUpdateString(updateReference))")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 20, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private var watchOverview: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                watchStatCard(title: "Refs", value: "\(quoteStore.quotes.count)")
                watchStatCard(
                    title: "Max venta",
                    value: premiumCurrencyString(highestSellQuote?.venta ?? 0),
                    accent: PremiumPalette.emeraldHighlight
                )
            }

            VStack(spacing: 8) {
                watchStatCard(title: "Refs", value: "\(quoteStore.quotes.count)")
                watchStatCard(
                    title: "Max venta",
                    value: premiumCurrencyString(highestSellQuote?.venta ?? 0),
                    accent: PremiumPalette.emeraldHighlight
                )
            }
        }
    }

    private var updateReference: String? {
        quoteStore.quotes.first?.fechaActualizacion
    }

    private var highestSellQuote: DollarInfoModel? {
        quoteStore.quotes.max { lhs, rhs in
            lhs.venta < rhs.venta
        }
    }

    private func watchStatCard(title: String, value: String, accent: Color = PremiumPalette.sand) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 16, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

#Preview {
    ContentView()
}
