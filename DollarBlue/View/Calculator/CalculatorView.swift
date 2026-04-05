//
//  CalculatorView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct CalculationView: View {
    @Environment(QuoteStore.self) private var quoteStore

    @State private var isCalcPesos = true
    @State private var montoIngresadoString = ""
    @State private var montoIngresado: Double = 0
    @FocusState private var montoFocused: Bool

    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    private var inputHelperText: String {
        isCalcPesos
            ? "Si ingresas dolares, la compra suele ser la referencia mas util para estimar pesos recibidos."
            : "Si ingresas pesos, la venta suele ser la referencia mas util para estimar dolares comprables."
    }

    private var suggestedAmounts: [Double] {
        isCalcPesos ? [50, 100, 500] : [10000, 50000, 100000]
    }

    var body: some View {
        let displayedQuotes = QuotePresentationSupport.sortedQuotes(quoteStore.quotes, order: selectedSortOrder)
        let resultsSubtitle = resultsSubtitle(for: montoIngresado)

        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                    PremiumSectionHeader(
                        eyebrow: "Conversion inteligente",
                        title: "Calculadora",
                        subtitle: "Monta un escenario rápido y compara compra y venta con una lectura mas limpia."
                    )

                    CalculationConversionPanel(
                        isCalcPesos: $isCalcPesos,
                        amountText: $montoIngresadoString,
                        amountValue: $montoIngresado,
                        amountFocused: $montoFocused,
                        inputHelperText: inputHelperText,
                        suggestedAmounts: suggestedAmounts,
                        applySuggestedAmount: applySuggestedAmount
                    )

                    CalculationResultsSection(
                        displayedQuotes: displayedQuotes,
                        resultsSubtitle: resultsSubtitle,
                        isLoading: quoteStore.isLoading,
                        amountValue: montoIngresado,
                        isCalcPesos: isCalcPesos,
                        useCompactCards: useCompactCards
                    )

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    montoFocused = false
                }
            )
            .refreshable {
                await quoteStore.refresh()
            }
            .toolbar {
                if montoFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Listo") {
                            montoFocused = false
                        }
                    }
                }
            }
        }
    }

    private func resultsSubtitle(for amount: Double) -> String {
        if amount > 0 {
            return "Escenario actual para \(premiumCurrencyString(amount)) con cada referencia."
        }

        return "Ingresa un monto para estimar compra y venta por mercado."
    }

    private func applySuggestedAmount(_ amount: Double) {
        montoIngresado = amount
        montoIngresadoString = premiumEditableAmountString(amount)
    }
}

#Preview {
    CalculationView()
        .environment(QuoteStore())
}
