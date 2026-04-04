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
import DollarNetworkManage

struct CalculationView: View {
    @State private var dataController = DollarNetworkManager()
    @State private var alertMessage: AppAlertMessage?
    @State private var isLoading = false

    @State private var isCalcPesos = true
    @State private var montoIngresadoString = ""
    @State private var montoIngresado: Double = 0
    @FocusState private var montoFocused: Bool

    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: useCompactCards ? 14 : 20) {
                    PremiumSectionHeader(
                        eyebrow: "Conversion inteligente",
                        title: "Calculadora",
                        subtitle: "Monta un escenario rápido y compara compra y venta con una lectura mas limpia."
                    )

                    conversionPanel
                    resultsSection
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
                await reload()
            }
            .task {
                await reloadIfNeeded()
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
        .background(PremiumScreenBackground())
        .alert(item: $alertMessage) { errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage.value), dismissButton: .default(Text("OK")))
        }
    }

    private var conversionPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Convertir")
                .font(.headline)

            CalculatorModeSelector(isCalcPesos: $isCalcPesos)

            VStack(alignment: .leading, spacing: 10) {
                Text(isCalcPesos ? "Monto en dolares" : "Monto en pesos")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Text(isCalcPesos ? "USD" : "ARS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(PremiumPalette.emeraldHighlight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(PremiumPalette.emerald.opacity(0.12))
                        }

                    CurrencyTextField(
                        text: $montoIngresadoString,
                        value: $montoIngresado,
                        placeholder: isCalcPesos ? "Ej: 100,00" : "Ej: 100000,00"
                    )
                    .focused($montoFocused)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .padding(.horizontal, 14)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(PremiumPalette.emerald.opacity(0.08))
                }

                Text(inputHelperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .premiumSurface(cornerRadius: 22, accent: PremiumPalette.sand, glassEnabled: true)

            VStack(alignment: .leading, spacing: 10) {
                Text("Accesos rapidos")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(suggestedAmounts, id: \.self) { amount in
                        Button {
                            applySuggestedAmount(amount)
                        } label: {
                            Text(premiumCurrencyString(amount))
                                .font(.footnote.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .premiumSurface(cornerRadius: 18, accent: PremiumPalette.emerald, glassEnabled: true)
                    }
                }
            }
        }
        .padding(20)
        .premiumSurface(cornerRadius: 30, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private var resultsSection: some View {
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

            if isLoading && dataController.cotizaciones.isEmpty {
                CalculatorStatusCard(message: "Calculando escenarios...", systemImage: "function")
            } else if dataController.cotizaciones.isEmpty {
                CalculatorStatusCard(
                    message: "Todavia no hay cotizaciones",
                    detail: "Desliza hacia abajo para recargar y volver a calcular.",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            } else {
                ForEach(displayedQuotes, id: \.nombre) { dolarInfo in
                    CalcRowView(
                        dolarInfo: dolarInfo,
                        montoIngresado: $montoIngresado,
                        isCalcPesos: $isCalcPesos
                    )
                }
            }
        }
    }

    private var suggestedAmounts: [Double] {
        isCalcPesos ? [50, 100, 500] : [10000, 50000, 100000]
    }

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    private var displayedQuotes: [DollarInfoModel] {
        QuotePresentationSupport.sortedQuotes(dataController.cotizaciones, order: selectedSortOrder)
    }

    private var inputHelperText: String {
        isCalcPesos
            ? "Si ingresas dolares, la compra suele ser la referencia mas util para estimar pesos recibidos."
            : "Si ingresas pesos, la venta suele ser la referencia mas util para estimar dolares comprables."
    }

    private var resultsSubtitle: String {
        if montoIngresado > 0 {
            return "Escenario actual para \(premiumCurrencyString(montoIngresado)) con cada referencia."
        }

        return "Ingresa un monto para estimar compra y venta por mercado."
    }

    private func applySuggestedAmount(_ amount: Double) {
        montoIngresado = amount
        montoIngresadoString = premiumEditableAmountString(amount)
    }

    private func reloadIfNeeded() async {
        guard dataController.cotizaciones.isEmpty else {
            return
        }

        await reload()
    }

    private func reload() async {
        isLoading = true
        alertMessage = await dataController.refreshFromServer()
        isLoading = false
    }
}

private struct CalculatorStatusCard: View {
    let message: String
    var detail: String? = nil
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(PremiumPalette.emeraldHighlight)

            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.headline)

                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.emerald, glassEnabled: true)
    }
}

private struct CalculatorModeSelector: View {
    @Binding var isCalcPesos: Bool

    var body: some View {
        HStack(spacing: 10) {
            modeButton(title: "A pesos", isSelected: isCalcPesos) {
                withAnimation(.smooth(duration: 0.24, extraBounce: 0)) {
                    isCalcPesos = true
                }
            }

            modeButton(title: "A dolares", isSelected: !isCalcPesos) {
                withAnimation(.smooth(duration: 0.24, extraBounce: 0)) {
                    isCalcPesos = false
                }
            }
        }
        .padding(8)
        .premiumSurface(cornerRadius: 22, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? Color.white : .primary.opacity(0.82))
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? PremiumPalette.emerald : Color.clear)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CalculationView()
}
