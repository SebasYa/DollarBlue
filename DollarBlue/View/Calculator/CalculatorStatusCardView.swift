//
//  CalculatorStatusCardView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 06/04/2026.
//

import SwiftUI

struct CalculatorStatusCardView: View {
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
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.emerald, glassEnabled: false)
    }
}

#Preview {
    CalculatorStatusCardView(message: "", systemImage: "")
}
