//
//  DollarRowView.swift
//  DollarBlueW Watch App
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct DollarRowView: View {
    var dolarInfo: DollarInfoModel
    
    var body: some View {
        VStack {
            Divider()
                .background(Color.red)
            Text("Dolar \(dolarInfo.nombre)")
                .font(.callout)
                .foregroundStyle(.linearGradient(colors: [.green, .white], startPoint: .top, endPoint: .bottom))
            VStack {
                HStack(alignment: .center) {
                    Text("Compra:")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.linearGradient(colors: [.green, .white], startPoint: .bottom, endPoint: .top))
                        .italic()
                    Text("$\(String(format: "%.2f",dolarInfo.compra))")
                        .font(.caption2)
                        .foregroundStyle(.linearGradient(colors: [.green, .white], startPoint: .bottom, endPoint: .top))
                }
                
                
                HStack {
                    Text("Venta:")
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.linearGradient(colors: [.green, .white], startPoint: .bottom, endPoint: .top))
                    Text("$\(String(format: "%.2f",dolarInfo.venta))")
                        .font(.caption2)
                        .foregroundStyle(.linearGradient(colors: [.green, .white], startPoint: .bottom, endPoint: .top))
                }
            }
        }
    }
}

#Preview {
    DollarRowView(dolarInfo: DollarInfoModel.placeholderModel)
}
