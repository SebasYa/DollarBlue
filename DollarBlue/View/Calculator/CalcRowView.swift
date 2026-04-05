//
//  CalcRowView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct CalcRowView: View, Equatable {
    let dolarInfo: DollarInfoModel
    let montoIngresado: Double
    let isCalcPesos: Bool
    let useCompactCards: Bool

    private var cardSpacing: CGFloat { useCompactCards ? 10 : 16 }
    private var cardPadding: CGFloat { useCompactCards ? 14 : 20 }
    private var iconSize: CGFloat { useCompactCards ? 36 : 42 }

    static func == (lhs: CalcRowView, rhs: CalcRowView) -> Bool {
        lhs.dolarInfo.nombre == rhs.dolarInfo.nombre &&
        lhs.dolarInfo.compra == rhs.dolarInfo.compra &&
        lhs.dolarInfo.venta == rhs.dolarInfo.venta &&
        lhs.montoIngresado == rhs.montoIngresado &&
        lhs.isCalcPesos == rhs.isCalcPesos &&
        lhs.useCompactCards == rhs.useCompactCards
    }

    var body: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dolarInfo.nombre)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                    Text(isCalcPesos ? "De dolares a pesos" : "De pesos a dolares")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Compra \(premiumCurrencyString(dolarInfo.compra))  |  Venta \(premiumCurrencyString(dolarInfo.venta))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "function")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .frame(width: iconSize, height: iconSize)
                    .background {
                        Circle()
                            .fill(PremiumPalette.emerald.opacity(0.14))
                    }
            }

            HStack(spacing: 12) {
                CalculatorValueColumn(
                    title: "Con compra",
                    value: resolvedAmount(for: dolarInfo.compra),
                    accent: .secondary,
                    compact: useCompactCards
                )

                CalculatorValueColumn(
                    title: "Con venta",
                    value: resolvedAmount(for: dolarInfo.venta),
                    accent: PremiumPalette.emeraldHighlight,
                    compact: useCompactCards
                )
            }
        }
        .padding(cardPadding)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private func resolvedAmount(for rate: Double) -> Double {
        guard montoIngresado > 0, rate > 0 else {
            return 0
        }

        return isCalcPesos ? rate * montoIngresado : montoIngresado / rate
    }
}

private struct CalculatorValueColumn: View {
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
                integerSize: compact ? 17 : 20,
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
    CalcRowView(
        dolarInfo: DollarInfoModel.placeholderModel,
        montoIngresado: 1,
        isCalcPesos: true,
        useCompactCards: false
    )
}
