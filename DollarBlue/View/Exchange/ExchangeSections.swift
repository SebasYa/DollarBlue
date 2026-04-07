//
//  ExchangeSections.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import SwiftUI
import DollarInfoModel

struct ExchangeSelectorSection: View {
    let quotes: [DolarAPIQuote]
    @Binding var selectedQuoteID: String
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Referencias globales")
                        .font(.title3.weight(.semibold))
                    Text("Explora las divisas actuales y fija una para tu cálculo.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(PremiumPalette.emeraldHighlight)
                }
            }

            if quotes.isEmpty {
                CalculatorStatusCardView(
                    message: "Todavía no hay divisas disponibles",
                    detail: "La sección Exchange se completa con la consulta de cotizaciones globales.",
                    systemImage: "globe.europe.africa.fill"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quotes) { quote in
                            ExchangeSelectionChip(
                                quote: quote,
                                isSelected: quote.id == selectedQuoteID
                            ) {
                                selectedQuoteID = quote.id
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

struct ExchangeSpotlightSection: View {
    let selectedQuote: DolarAPIQuote?
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seleccion actual")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            if let selectedQuote {
                ExchangeSpotlightCard(quote: selectedQuote)
            } else if isLoading {
                CalculatorStatusCardView(message: "Consultando divisas...", systemImage: "globe")
            } else {
                CalculatorStatusCardView(
                    message: "Selecciona una divisa",
                    detail: "Cuando haya una referencia disponible la verás destacada aquí.",
                    systemImage: "arrow.left.arrow.right.circle"
                )
            }
        }
    }
}
