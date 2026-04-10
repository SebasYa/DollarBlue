//
//  CalculationResultsSectionView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 06/04/2026.
//

import SwiftUI
import DollarInfoModel

struct CalculationResultsSectionView: View, Equatable {
    let displayedQuotes: [DollarInfoModel]
    let resultsSubtitle: String
    let isLoading: Bool
    let amountValue: Double
    let isCalcPesos: Bool
    let useCompactCards: Bool

    static func == (lhs: CalculationResultsSectionView, rhs: CalculationResultsSectionView) -> Bool {
        lhs.displayedQuotes.count == rhs.displayedQuotes.count &&
        zip(lhs.displayedQuotes, rhs.displayedQuotes).allSatisfy { lhsQuote, rhsQuote in
            lhsQuote.nombre == rhsQuote.nombre &&
            lhsQuote.compra == rhsQuote.compra &&
            lhsQuote.venta == rhsQuote.venta
        } &&
        lhs.resultsSubtitle == rhs.resultsSubtitle &&
        lhs.isLoading == rhs.isLoading &&
        lhs.amountValue == rhs.amountValue &&
        lhs.isCalcPesos == rhs.isCalcPesos &&
        lhs.useCompactCards == rhs.useCompactCards
    }

    var body: some View {
        VStack(alignment: .leading, spacing: useCompactCards ? 12 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resultados")
                        .font(.title3.weight(.semibold))
                    Text(resultsSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(PremiumPalette.emeraldHighlight)
                }
            }

            if isLoading && displayedQuotes.isEmpty {
                CalculatorStatusCardView(message: "Calculando escenarios...", systemImage: "function")
            } else if displayedQuotes.isEmpty {
                CalculatorStatusCardView(
                    message: "Todavia no hay cotizaciones",
                    detail: "Actualiza el mercado desde Home para recalcular con nuevas referencias.",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            } else {
                LazyVStack(spacing: useCompactCards ? 12 : 16) {
                    ForEach(displayedQuotes, id: \.nombre) { dolarInfo in
                        CalcRowView(
                            dolarInfo: dolarInfo,
                            montoIngresado: amountValue,
                            isCalcPesos: isCalcPesos,
                            useCompactCards: useCompactCards
                        )
                        .equatable()
                    }
                }
            }
        }
        
    }
}

#Preview {
    CalculationResultsSectionView(
        displayedQuotes: [],
        resultsSubtitle: "",
        isLoading: false,
        amountValue: 0.0,
        isCalcPesos: false,
        useCompactCards: false
    )
}
