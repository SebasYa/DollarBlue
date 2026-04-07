//
//  CalculationConversionPanelView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 06/04/2026.
//

import SwiftUI

struct CalculationConversionPanelView: View {
    @Binding var isCalcPesos: Bool
    @Binding var amountText: String
    var amountFocused: FocusState<Bool>.Binding
    let isEditingAmount: Bool
    let inputHelperText: String
    let suggestedAmounts: [Double]
    let applySuggestedAmount: (Double) -> Void
    let submitAmount: () -> Void
    var sectionTitle: String = "Convertir"
    var firstModeTitle: String = "A pesos"
    var secondModeTitle: String = "A dolares"
    var inputAmountTitle: String = "Monto en dolares"
    var foreignCurrencyCode: String = "USD"
    var foreignPlaceholder: String = "Ej: 100,00"
    var localCurrencyCode: String = "ARS"
    var localPlaceholder: String = "Ej: 100000,00"

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(sectionTitle)
                .font(.headline)

            VStack(spacing: 10) {
                CalculatorModeSelectorView(
                    isCalcPesos: $isCalcPesos,
                    firstModeTitle: firstModeTitle,
                    secondModeTitle: secondModeTitle
                )
                CalculatorAmountFieldRowView(
                    isCalcPesos: isCalcPesos,
                    amountText: $amountText,
                    amountFocused: amountFocused,
                    submitAmount: submitAmount,
                    foreignCurrencyCode: foreignCurrencyCode,
                    foreignPlaceholder: foreignPlaceholder,
                    localCurrencyCode: localCurrencyCode,
                    localPlaceholder: localPlaceholder
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(isCalcPesos ? inputAmountTitle : "Monto en pesos")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(inputHelperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if isEditingAmount {
                    HStack(spacing: 8) {
                        Image(systemName: "keyboard")
                            .font(.caption.weight(.semibold))
                        Text("Toca Calcular en el teclado para aplicar el monto o fuera del campo para cancelar.")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                }
            }
            .padding(16)
            .premiumSurface(cornerRadius: 22, accent: PremiumPalette.sand, glassEnabled: false)

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
                        .premiumSurface(cornerRadius: 18, accent: PremiumPalette.emerald, glassEnabled: false)
                    }
                }
            }
        }
        .padding(20)
        .premiumSurface(cornerRadius: 30, accent: PremiumPalette.emerald, glassEnabled: false)
    }
}

private struct CalculationConversionPanelPreviewHost: View {
    @State private var isCalcPesos = true
    @State private var amountText = "100"
    @FocusState private var amountFocused: Bool

    var body: some View {
        CalculationConversionPanelView(
            isCalcPesos: $isCalcPesos,
            amountText: $amountText,
            amountFocused: $amountFocused,
            isEditingAmount: false,
            inputHelperText: "Ingresa un monto para ver la conversion.",
            suggestedAmounts: [50, 100, 200],
            applySuggestedAmount: { amount in
                amountText = premiumCurrencyString(amount)
            },
            submitAmount: {}
        )
        .padding()
    }
}

#Preview {
    @Previewable @State var isCalcPesos = true
    @Previewable @State var amountText = "100"
    @FocusState var amountFocused: Bool
    
    CalculationConversionPanelView(
        isCalcPesos: $isCalcPesos,
        amountText: $amountText,
        amountFocused: $amountFocused,
        isEditingAmount: false,
        inputHelperText: "Ingresa un monto para ver la conversión.",
        suggestedAmounts: [50, 100, 200],
        applySuggestedAmount: { amount in
            amountText = premiumCurrencyString(amount)
        },
        submitAmount: {}
    )
    
}
