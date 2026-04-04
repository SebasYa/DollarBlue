//
//  DollarRowView.swift
//  DollarBlueW Watch App
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct DollarRowView: View {
    let dolarInfo: DollarInfoModel

    private var compactName: String {
        QuotePresentationSupport.compactDisplayName(for: dolarInfo.nombre)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(compactName)
                .font(.system(.headline, design: .serif).weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    watchValueBlock(title: "Compra", value: dolarInfo.compra)
                    watchValueBlock(title: "Venta", value: dolarInfo.venta, accent: PremiumPalette.emeraldHighlight)
                }

                VStack(spacing: 8) {
                    watchValueBlock(title: "Compra", value: dolarInfo.compra)
                    watchValueBlock(title: "Venta", value: dolarInfo.venta, accent: PremiumPalette.emeraldHighlight)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 18, accent: PremiumPalette.emerald, glassEnabled: true)
    }

    private func watchValueBlock(title: String, value: Double, accent: Color = .secondary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            PremiumCurrencyValueText(
                value: value,
                accent: accent,
                integerSize: 15,
                centsSize: 11
            )
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PremiumPalette.emerald.opacity(0.08))
        }
    }
}

#Preview {
    DollarRowView(dolarInfo: DollarInfoModel.placeholderModel)
}
