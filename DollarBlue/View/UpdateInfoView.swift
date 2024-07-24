//
//  UpdateInfoView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct UpdateInfoView: View {
    
    var dolarInfo: DollarInfoModel
    
    var body: some View {
        HStack{
            Image(systemName: "arrow.triangle.2.circlepath")
                .imageScale(.small)
            Text("fecha de actualizacion: \(dolarInfo.fechaActualizacion)")
                .font(.footnote)
                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
        }
        .font(.footnote)
        .presentationCornerRadius(10)
    }
}

#Preview {
    UpdateInfoView(dolarInfo: DollarInfoModel.placeholderModel)
}

