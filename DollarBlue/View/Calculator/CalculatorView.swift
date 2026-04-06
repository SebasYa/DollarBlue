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
    @State private var inputSession = CalculatorInputSession()
    @State private var displayedQuotes = [DollarInfoModel]()
    @State private var amountFieldFrame: CGRect = .zero
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
        let resultsSubtitle = resultsSubtitle(for: inputSession.committedValue)

        NavigationStack {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                        PremiumSectionHeader(
                            eyebrow: "Conversion inteligente",
                            title: "Calculadora",
                            subtitle: "Convertir de Pesos a Dólares o de Dólares a Pesos Fácil y Rápido."
                        )

                        CalculationConversionPanelView(
                            isCalcPesos: $isCalcPesos,
                            amountText: amountTextBinding,
                            amountFocused: $montoFocused,
                            isEditingAmount: inputSession.isEditing,
                            inputHelperText: inputHelperText,
                            suggestedAmounts: suggestedAmounts,
                            applySuggestedAmount: applySuggestedAmount,
                            submitAmount: acceptEditing
                        )
                        .id(CalculatorScrollTarget.amountInput)

                        CalculationResultsSectionView(
                            displayedQuotes: displayedQuotes,
                            resultsSubtitle: resultsSubtitle,
                            isLoading: quoteStore.isLoading,
                            amountValue: inputSession.committedValue,
                            isCalcPesos: isCalcPesos,
                            useCompactCards: useCompactCards
                        )
                        .equatable()

                        FloatingTabBarFooterSpacer(extraPadding: 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 10)
                }
                .coordinateSpace(name: CalculatorLayout.coordinateSpaceName)
                .scrollDisabled(montoFocused)
                .scrollDismissesKeyboard(.never)
                .overlay {
                    if montoFocused, amountFieldFrame != .zero {
                        CalculatorDismissOverlay(
                            focusFrame: amountFieldFrame,
                            onCancel: cancelEditing
                        )
                    }
                }
                .onChange(of: montoFocused) { _, isFocused in
                    if isFocused {
                        beginEditing()
                        withAnimation(.snappy(duration: 0.22)) {
                            scrollProxy.scrollTo(CalculatorScrollTarget.amountInput, anchor: .center)
                        }
                    } else if inputSession.isEditing {
                        cancelEditing()
                    }
                }
                .onPreferenceChange(CalculatorAmountFieldFramePreferenceKey.self) { newValue in
                    amountFieldFrame = newValue
                }
            }
        }
        .preference(key: CustomTabBarHiddenPreferenceKey.self, value: montoFocused)
        .transaction { transaction in
            if montoFocused {
                transaction.animation = nil
            }
        }
        .task(id: presentationDependencies) {
            displayedQuotes = QuotePresentationSupport.sortedQuotes(quoteStore.quotes, order: selectedSortOrder)
        }
    }

    private func resultsSubtitle(for amount: Double) -> String {
        if amount > 0 {
            return "Escenario actual para \(premiumCurrencyString(amount)) con cada referencia."
        }

        return "Ingresa un monto para estimar compra y venta por mercado."
    }

    private func applySuggestedAmount(_ amount: Double) {
        inputSession.setCommittedAmount(amount)
        montoFocused = false
    }

    private func beginEditing() {
        inputSession.startEditing()
    }

    private func acceptEditing() {
        guard inputSession.isEditing || montoFocused else {
            return
        }

        inputSession.acceptDraft()
        montoFocused = false
    }

    private func cancelEditing() {
        guard inputSession.isEditing || montoFocused else {
            return
        }

        inputSession.cancelDraft()
        montoFocused = false
    }

    private var amountTextBinding: Binding<String> {
        Binding(
            get: { inputSession.activeText },
            set: { newValue in
                inputSession.updateDraft(text: newValue)
            }
        )
    }

    private var presentationDependencies: CalculatorPresentationDependencies {
        CalculatorPresentationDependencies(
            refreshRevision: quoteStore.refreshRevision,
            quotesCount: quoteStore.quotes.count,
            sortOrder: selectedSortOrder
        )
    }
}

private enum CalculatorScrollTarget {
    static let amountInput = "calculator-amount-input"
}

private struct CalculatorPresentationDependencies: Hashable {
    let refreshRevision: Int
    let quotesCount: Int
    let sortOrder: QuoteSortOrder
}

#Preview {
    CalculationView()
        .environment(QuoteStore())
}
