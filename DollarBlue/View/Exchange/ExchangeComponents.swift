//
//  ExchangeComponents.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import Foundation
import SwiftUI
import DollarInfoModel

struct ExchangeSelectionChip: View {
    let quote: DolarAPIQuote
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ExchangeMonogramBadge(label: quote.exchangeCode, isSelected: isSelected)

                Text(quote.exchangeDisplayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(isSelected ? PremiumPalette.emerald.opacity(0.16) : PremiumPalette.emerald.opacity(0.08))
                    .overlay {
                        Capsule()
                            .stroke(
                                isSelected ? PremiumPalette.emeraldHighlight.opacity(0.55) : Color.white.opacity(0.16),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ExchangeSpotlightCard: View {
    let quote: DolarAPIQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quote.exchangeDisplayName)
                        .font(.system(.title2, design: .serif).weight(.semibold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        PremiumPill(icon: "globe", label: quote.exchangeCode)

                        if !quote.casa.isEmpty {
                            PremiumPill(icon: "arrow.left.arrow.right", label: quote.casa.uppercased())
                        }
                    }
                }

                Spacer()

                ExchangeMonogramBadge(label: quote.exchangeCode, isSelected: true, size: 52)
            }

            HStack(spacing: 12) {
                ExchangeValueTile(
                    title: "Compra",
                    value: quote.compra,
                    accent: .primary
                )

                ExchangeValueTile(
                    title: "Venta",
                    value: quote.venta,
                    accent: .primary
                )
            }

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.caption.weight(.semibold))
                Text("Referencia \(premiumCompactUpdateString(quote.fechaActualizacion))")
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .premiumSurface(cornerRadius: 30, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

private struct ExchangeValueTile: View {
    let title: String
    let value: Double
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(PremiumPalette.emeraldHighlight)

            PremiumCurrencyValueText(
                value: value,
                accent: accent,
                integerSize: 23,
                centsSize: 14
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 20, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

private struct ExchangeMonogramBadge: View {
    let label: String
    let isSelected: Bool
    var size: CGFloat = 38

    var body: some View {
        Text(label)
            .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
            .foregroundStyle(isSelected ? Color.white : PremiumPalette.emeraldHighlight)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(isSelected ? PremiumPalette.emeraldHighlight : PremiumPalette.emerald.opacity(0.12))
            }
    }
}

extension DolarAPIQuote {
    var exchangeCode: String {
        let code = moneda.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if !code.isEmpty, code.count <= 4 {
            return code
        }

        return String(exchangeDisplayName.prefix(2)).uppercased()
    }

    var exchangeDisplayName: String {
        let normalizedName = nombre
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_AR"))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch exchangeCode {
        case "EUR":
            return "Euro "
        case "BRL":
            return "Real "
        case "UYU":
            return "Peso uruguayo"
        case "CLP":
            return "Peso chileno"
        default:
            if normalizedName.lowercased().contains("dolar") {
                return ""
            }

            return QuotePresentationSupport.compactDisplayName(for: nombre)
        }
    }

    var exchangeSortPriority: Int {
        switch exchangeCode {
        case "EUR":
            return 0
        case "BRL":
            return 1
        case "UYU":
            return 2
        case "CLP":
            return 3
        default:
            return 100
        }
    }

    var isDollarReference: Bool {
        exchangeCode == "USD" || nombre.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_AR")).lowercased().contains("dolar")
    }
}
