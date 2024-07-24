//
//  CalcRowView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct CalcRowView: View {
    // MARK: - PROPERTIES
    var dolarInfo: DollarInfoModel
    @Binding var montoIngresado: Double
    @Binding var isCalcPesos: Bool
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }
    
    // MARK: - BODY
    var body: some View {
        
        GroupBox {
            HStack {
                Text("Dólar \(dolarInfo.nombre)")
                    .font(.title2)
                    .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Text("Compra: ")
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                            .italic()
                        
                        if montoIngresado > 0 {
                            let formattedValue = isCalcPesos ? dolarInfo.compra * montoIngresado : montoIngresado / dolarInfo.compra
                            Text("$\(numberFormatter.string(from: NSNumber(value: formattedValue)) ?? "0,00")")
                                .font(.title3)
                                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: 150)
                                .scaledToFit()
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text("$0,00")
                                .font(.title3)
                                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text("Venta: ")
                            .font(.headline)
                            .italic()
                            .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                        
                        if montoIngresado > 0 {
                            let formattedValue = isCalcPesos ? dolarInfo.venta * montoIngresado : montoIngresado / dolarInfo.venta

                            Text("$\(numberFormatter.string(from: NSNumber(value: formattedValue)) ?? "0,00")")
                                .font(.title3)
                                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: 150)
                                .scaledToFit()
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text("$0,00")
                                .font(.title3)
                                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    CalcRowView(dolarInfo: DollarInfoModel.placeholderModel, montoIngresado: .constant(1), isCalcPesos: .constant(true))
}
