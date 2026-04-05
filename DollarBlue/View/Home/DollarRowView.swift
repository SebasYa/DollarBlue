//
//  DollarRowView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct DollarRowView: View, Equatable {
    let dolarInfo: DollarInfoModel
    let useCompactCards: Bool
    let showUpdateStamp: Bool

    private var cardSpacing: CGFloat { useCompactCards ? 10 : 16 }
    private var cardPadding: CGFloat { useCompactCards ? 14 : 20 }
    private var iconSize: CGFloat { useCompactCards ? 36 : 42 }

    static func == (lhs: DollarRowView, rhs: DollarRowView) -> Bool {
        lhs.dolarInfo.nombre == rhs.dolarInfo.nombre &&
        lhs.dolarInfo.compra == rhs.dolarInfo.compra &&
        lhs.dolarInfo.venta == rhs.dolarInfo.venta &&
        lhs.dolarInfo.fechaActualizacion == rhs.dolarInfo.fechaActualizacion &&
        lhs.useCompactCards == rhs.useCompactCards &&
        lhs.showUpdateStamp == rhs.showUpdateStamp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dolarInfo.nombre)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(useCompactCards ? "Compra, venta y spread" : "Mercado argentino")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "dollarsign.arrow.circlepath")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .frame(width: iconSize, height: iconSize)
                    .background {
                        Circle()
                            .fill(PremiumPalette.emerald.opacity(0.14))
                    }
            }

            HStack(spacing: 12) {
                QuoteValueColumn(
                    title: "Compra",
                    value: dolarInfo.compra,
                    accent: .secondary,
                    compact: useCompactCards
                )

                QuoteValueColumn(
                    title: "Venta",
                    value: dolarInfo.venta,
                    accent: PremiumPalette.emeraldHighlight,
                    compact: useCompactCards
                )
            }

            HStack(spacing: useCompactCards ? 6 : 8) {
                Label("Spread \(premiumCurrencyString(spreadValue))", systemImage: "arrow.left.and.right")
                    .font(.caption.weight(.semibold))
                Text(premiumPercentageString(spreadPercentage))
                    .font(.caption)
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)

            if showUpdateStamp, !dolarInfo.fechaActualizacion.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption.weight(.semibold))
                    Text("Referencia \(premiumCompactUpdateString(dolarInfo.fechaActualizacion))")
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(cardPadding)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private var spreadValue: Double {
        max(0, dolarInfo.venta - dolarInfo.compra)
    }

    private var spreadPercentage: Double {
        guard dolarInfo.compra > 0 else {
            return 0
        }

        return (spreadValue / dolarInfo.compra) * 100
    }
}

private struct QuoteValueColumn: View {
    let title: String
    let value: Double
    let accent: Color
    let compact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(.secondary)

            PremiumCurrencyValueText(
                value: value,
                accent: accent,
                integerSize: compact ? 18 : 22,
                centsSize: compact ? 12 : 14
            )
        }
        .padding(compact ? 12 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PremiumPalette.emerald.opacity(0.08))
        }
    }
}

#Preview {
    DollarRowView(
        dolarInfo: DollarInfoModel.placeholderModel,
        useCompactCards: false,
        showUpdateStamp: true
    )
}
