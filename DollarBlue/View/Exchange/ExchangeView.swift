//
//  ExchangeView.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import SwiftUI
import DollarInfoModel

struct ExchangeView: View {
    @Environment(QuoteStore.self) private var quoteStore

    @State private var isCalcPesos = true
    @State private var inputSession = CalculatorInputSession()
    @State private var amountFieldFrame: CGRect = .zero
    @FocusState private var amountFocused: Bool

    @AppStorage("selectedExchangeQuoteID") private var selectedExchangeQuoteID = ""
    @AppStorage("useCompactCards") private var useCompactCards = false

    private var sortedCurrencyQuotes: [DolarAPIQuote] {
        quoteStore.currencyQuotes
            .filter { !$0.isDollarReference }
            .sorted { lhs, rhs in
                if lhs.exchangeSortPriority == rhs.exchangeSortPriority {
                    if lhs.exchangeDisplayName == rhs.exchangeDisplayName {
                        return lhs.id < rhs.id
                    }

                    return lhs.exchangeDisplayName < rhs.exchangeDisplayName
                }

                return lhs.exchangeSortPriority < rhs.exchangeSortPriority
            }
    }

    private var selectedQuote: DolarAPIQuote? {
        if let storedQuote = sortedCurrencyQuotes.first(where: { $0.id == selectedExchangeQuoteID }) {
            return storedQuote
        }

        return sortedCurrencyQuotes.first
    }

    private var selectedResults: [DollarInfoModel] {
        guard let selectedQuote else {
            return []
        }

        return [selectedQuote.legacyDollarInfoModel]
    }

    private var inputHelperText: String {
        isCalcPesos
            ? "Si ingresas \(selectedCurrencyTitleLowercased), la compra suele ser la referencia más útil para estimar pesos recibidos."
            : "Si ingresas pesos, la venta suele ser la referencia más útil para estimar \(selectedCurrencyTitleLowercased) comprables."
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
                            eyebrow: "Mercado global",
                            title: "Exchange",
                            subtitle: "Selecciona una divisa actual y calcula su compra o venta con el mismo lenguaje premium de la app."
                        )

                        ExchangeSelectorSection(
                            quotes: sortedCurrencyQuotes,
                            selectedQuoteID: $selectedExchangeQuoteID,
                            isLoading: quoteStore.isCurrenciesLoading
                        )

                        ExchangeSpotlightSection(
                            selectedQuote: selectedQuote,
                            isLoading: quoteStore.isCurrenciesLoading
                        )

                        CalculationConversionPanelView(
                            isCalcPesos: $isCalcPesos,
                            amountText: amountTextBinding,
                            amountFocused: $amountFocused,
                            isEditingAmount: inputSession.isEditing,
                            inputHelperText: inputHelperText,
                            suggestedAmounts: suggestedAmounts,
                            applySuggestedAmount: applySuggestedAmount,
                            submitAmount: acceptEditing,
                            secondModeTitle: "A \(selectedCurrencyTitle)",
                            inputAmountTitle: "Monto en \(selectedCurrencyTitleLowercased)",
                            foreignCurrencyCode: selectedCurrencyCode
                        )
                        .id(ExchangeScrollTarget.amountInput)

                        CalculationResultsSectionView(
                            displayedQuotes: selectedResults,
                            resultsSubtitle: resultsSubtitle,
                            isLoading: quoteStore.isCurrenciesLoading,
                            amountValue: inputSession.committedValue,
                            isCalcPesos: isCalcPesos,
                            useCompactCards: useCompactCards
                        )
                        .equatable()

                        FloatingTabBarFooterSpacer(extraPadding: 14)
                    }
                    .padding(.horizontal, PremiumLayout.screenHorizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 10)
                }
                .coordinateSpace(name: CalculatorLayout.coordinateSpaceName)
                .scrollDisabled(amountFocused)
                .scrollDismissesKeyboard(.never)
                .overlay {
                    if amountFocused, amountFieldFrame != .zero {
                        CalculatorDismissOverlay(
                            focusFrame: amountFieldFrame,
                            onCancel: cancelEditing
                        )
                    }
                }
                .onChange(of: amountFocused) { _, isFocused in
                    if isFocused {
                        beginEditing()
                        withAnimation(.snappy(duration: 0.22)) {
                            scrollProxy.scrollTo(ExchangeScrollTarget.amountInput, anchor: .center)
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
        .preference(key: CustomTabBarHiddenPreferenceKey.self, value: amountFocused)
        .transaction { transaction in
            if amountFocused {
                transaction.animation = nil
            }
        }
        .task {
            await quoteStore.loadCurrenciesIfNeeded()
            syncSelection()
        }
        .task(id: presentationDependencies) {
            syncSelection()
        }
    }

    private func resultsSubtitle(for amount: Double) -> String {
        guard let selectedQuote else {
            return "Selecciona una divisa para calcular su escenario actual."
        }

        if amount > 0 {
            return "Escenario actual para \(premiumCurrencyString(amount)) en \(selectedQuote.exchangeDisplayName)."
        }

        return "Ingresa un monto para estimar compra y venta en \(selectedQuote.exchangeDisplayName)."
    }

    private func applySuggestedAmount(_ amount: Double) {
        inputSession.setCommittedAmount(amount)
        amountFocused = false
    }

    private func beginEditing() {
        inputSession.startEditing()
    }

    private func acceptEditing() {
        guard inputSession.isEditing || amountFocused else {
            return
        }

        inputSession.acceptDraft()
        amountFocused = false
    }

    private func cancelEditing() {
        guard inputSession.isEditing || amountFocused else {
            return
        }

        inputSession.cancelDraft()
        amountFocused = false
    }

    private func syncSelection() {
        guard let firstQuote = sortedCurrencyQuotes.first else {
            selectedExchangeQuoteID = ""
            return
        }

        if sortedCurrencyQuotes.contains(where: { $0.id == selectedExchangeQuoteID }) {
            return
        }

        selectedExchangeQuoteID = firstQuote.id
    }

    private var amountTextBinding: Binding<String> {
        Binding(
            get: { inputSession.activeText },
            set: { newValue in
                inputSession.updateDraft(text: newValue)
            }
        )
    }

    private var selectedCurrencyTitle: String {
        selectedQuote?.exchangeDisplayName ?? "divisa"
    }

    private var selectedCurrencyTitleLowercased: String {
        selectedCurrencyTitle.lowercased()
    }

    private var selectedCurrencyCode: String {
        selectedQuote?.exchangeCode ?? "DIV"
    }

    private var presentationDependencies: ExchangePresentationDependencies {
        ExchangePresentationDependencies(
            refreshRevision: quoteStore.currencyRefreshRevision,
            quotesCount: quoteStore.currencyQuotes.count,
            selectedQuoteID: selectedExchangeQuoteID
        )
    }
}

private enum ExchangeScrollTarget {
    static let amountInput = "exchange-amount-input"
}

private struct ExchangePresentationDependencies: Hashable {
    let refreshRevision: Int
    let quotesCount: Int
    let selectedQuoteID: String
}

#Preview {
    ExchangeView()
        .environment(QuoteStore())
}
