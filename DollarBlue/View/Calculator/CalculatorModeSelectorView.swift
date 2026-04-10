//
//  CalculatorModeSelectorView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 06/04/2026.
//

import SwiftUI

struct CalculatorModeSelectorView: View {
    @Binding var isCalcPesos: Bool
    var firstModeTitle: String = "A pesos"
    var secondModeTitle: String = "A dolares"

    var body: some View {
        HStack(spacing: 10) {
            modeButton(title: firstModeTitle, isSelected: isCalcPesos) {
                withAnimation(.smooth(duration: 0.24, extraBounce: 0)) {
                    isCalcPesos = true
                }
            }

            modeButton(title: secondModeTitle, isSelected: !isCalcPesos) {
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
            if #available(iOS 26.0, *) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(isSelected ? Color.white : .primary.opacity(0.82))
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSelected ? PremiumPalette.emerald : Color.clear)
                    }
                    .glassEffect(
                        .regular.tint(PremiumPalette.emerald.opacity(isSelected ? 0.24 : 0.14)),
                        in: .rect(cornerRadius: 16)
                    )
            } else {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(isSelected ? Color.white : .primary.opacity(0.82))
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSelected ? PremiumPalette.emerald : Color.clear)
                    }
                
                    .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    CalculatorModeSelectorView(isCalcPesos: .constant(false))
}
