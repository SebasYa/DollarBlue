//
//  DollarRowView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct DollarRowView: View {
    //MARK: - PROPERTIES

    var dolarInfo: DollarInfoModel
    
    //MARK: - BODY
    
    var body: some View {
        GroupBox {
            HStack(spacing: 20) {
                
                Text("Dolar \(dolarInfo.nombre)")
                    .font(.title2)
                    .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        Text("Compra:")
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                            .italic()
                        Text("$\(String(format: "%.2f",dolarInfo.compra))")
                            .font(.title3)
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                            .multilineTextAlignment(.center)
                    }
                    
                    
                    HStack {
                        Spacer()
                        Text("Venta:")
                            .font(.headline)
                            .italic()
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                        Text("$\(String(format: "%.2f",dolarInfo.venta))")
                            .font(.title3)
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                    }
                    
                }
            }
        }
    }
}


//MARK: - PREVIEW
#Preview {
    DollarRowView(dolarInfo: DollarInfoModel.placeholderModel)
}
