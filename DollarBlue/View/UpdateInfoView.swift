//
//  UpdateInfoView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarInfoModel

struct UpdateInfoView: View {
    var dolarInfo: DollarInfoModel
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PremiumPalette.emeraldHighlight)

            VStack(alignment: .leading, spacing: 2) {
                Text("Referencia")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(premiumCompactUpdateString(dolarInfo.fechaActualizacion))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 18, accent: PremiumPalette.sand, glassEnabled: false)
    }
}

#Preview {
    UpdateInfoView(dolarInfo: DollarInfoModel.placeholderModel)
}
