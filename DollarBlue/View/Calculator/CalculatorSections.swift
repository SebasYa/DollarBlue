//
//  CalculatorSections.swift
//  DollarBlue
//
//  Created by Codex on 05/04/2026.
//

import SwiftUI
import DollarInfoModel

struct CalculationConversionPanel: View {
    @Binding var isCalcPesos: Bool
    @Binding var amountText: String
    @Binding var amountValue: Double
    var amountFocused: FocusState<Bool>.Binding
    let inputHelperText: String
    let suggestedAmounts: [Double]
    let applySuggestedAmount: (Double) -> Void

    var body: some View {
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
                        text: $amountText,
                        value: $amountValue,
                        placeholder: isCalcPesos ? "Ej: 100,00" : "Ej: 100000,00"
                    )
                    .focused(amountFocused)
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
}

struct CalculationResultsSection: View {
    let displayedQuotes: [DollarInfoModel]
    let resultsSubtitle: String
    let isLoading: Bool
    let amountValue: Double
    let isCalcPesos: Bool
    let useCompactCards: Bool

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
                CalculatorStatusCard(message: "Calculando escenarios...", systemImage: "function")
            } else if displayedQuotes.isEmpty {
                CalculatorStatusCard(
                    message: "Todavia no hay cotizaciones",
                    detail: "Desliza hacia abajo para recargar y volver a calcular.",
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

struct CalculatorStatusCard: View {
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

struct CalculatorModeSelector: View {
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
