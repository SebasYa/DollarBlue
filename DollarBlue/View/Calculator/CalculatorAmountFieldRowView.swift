//
//  CalculatorAmountFieldRowView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 06/04/2026.
//

import SwiftUI

struct CalculatorAmountFieldRowView: View {
    let isCalcPesos: Bool
    @Binding var amountText: String
    var amountFocused: FocusState<Bool>.Binding
    let submitAmount: () -> Void
    var foreignCurrencyCode: String = "USD"
    var foreignPlaceholder: String = "Ej: 100,00"
    var localCurrencyCode: String = "ARS"
    var localPlaceholder: String = "Ej: 100000,00"

    var body: some View {
        HStack(spacing: 12) {
            Text(isCalcPesos ? foreignCurrencyCode : localCurrencyCode)
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
                placeholder: isCalcPesos ? foreignPlaceholder : localPlaceholder,
                onSubmit: submitAmount
            )
            .focused(amountFocused)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .premiumSurface(cornerRadius: 18, accent: PremiumPalette.sand, glassEnabled: true)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: CalculatorAmountFieldFramePreferenceKey.self,
                        value: proxy.frame(in: .named(CalculatorLayout.coordinateSpaceName))
                    )
            }
        }
    }
}
#Preview {
    @FocusState var amountFocused: Bool
    
    CalculatorAmountFieldRowView(
        isCalcPesos: false,
        amountText: .constant(""),
        amountFocused: $amountFocused,
        submitAmount: {}
    )
}
