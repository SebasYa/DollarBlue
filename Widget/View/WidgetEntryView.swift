//
//  WidgetEntryView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                if widgetFamily != .accessoryRectangular {
                    Image("ImageFranklin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 45)
                        .padding(.trailing, 9)
                        .padding(.bottom, -5)
                    
                    if widgetFamily == .systemMedium {
                        Text("DOLAR")
                            .foregroundStyle(.green)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, -10)
                            .padding(.trailing, 6)
                    } else {
                        Spacer()
                    }
                    
                    Image("ImageRoca")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 45)
                        .padding(.leading, 9)
                        .padding(.bottom, -4)
                        .scaleEffect(x: -1, y: 1, anchor: .center) //mirror image
                }
            }
            .padding(.top, -20)
            
            quotesView()
                .font(.body)
                .padding([.leading, .trailing], 5)
            
        }
    }
    
    @ViewBuilder
    private func quotesView() -> some View {
        
        VStack(alignment: .listRowSeparatorLeading, spacing: 2) {
            quoteView(dolarInfo: entry.dolarInfo1)
            Divider()
            quoteView(dolarInfo: entry.dolarInfo2)
        }
    }
    
    @ViewBuilder
    private func quoteView(dolarInfo: DollarInfoModel) -> some View {
        
        //MARK: - Config system Widget
        if widgetFamily != .accessoryRectangular {
            VStack(alignment: .listRowSeparatorLeading, spacing: 2) {
                HStack {
                    Text("Dolar \(dolarInfo.nombre):")
                        .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                        .font(.callout)
                    
                    Spacer()
                    if widgetFamily == .systemMedium{
                        VStack(alignment: .listRowSeparatorLeading){
                            Text("Compra: $\(String(format: "%.2f", (dolarInfo.compra)))")
                            Text("Venta:    $\(String(format: "%.2f", (dolarInfo.venta)))")
                        }
                        .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                        .font(.callout)
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    } else {
                        VStack(alignment: .listRowSeparatorLeading){
                            Text("Compra: $\(String(format: "%.2f", (dolarInfo.compra)))")
                            Text("Venta:    $\(String(format: "%.2f", (dolarInfo.venta)))")
                        }
                        .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .bottom, endPoint: .top))
                        .font(.caption2)
                        .bold()
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    }
                }
                .lineLimit(nil)
                .minimumScaleFactor(0.5)
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding([.leading, .trailing], 5)
            //MARK: -  Config block screen widget
        } else {
            VStack {
                HStack {
                    Text("Dolar \(dolarInfo.nombre):")
                        .font(.body)
                        .bold()
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("C: $\(String(format: "%.2f", dolarInfo.compra))")
                        Text("V: $\(String(format: "%.2f", dolarInfo.venta))")
                    }
                    .font(.caption2)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .bold()
                }
            }
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
        }
    }
}


#Preview(as: .systemMedium) {
    DollarBlueWidget()
} timeline: {
    SimpleEntry(date: .now, dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel(nombre: "Contado con liquidación", compra: 1000, venta: 1000, fechaActualizacion: "") )
}

#Preview("Small", as: .systemSmall) {
    DollarBlueWidget()
} timeline: {
    SimpleEntry(date: .now, dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel(nombre: "Contado con liquidación", compra: 1000, venta: 1000, fechaActualizacion: "") )
}

#Preview("LockScreen", as: .accessoryRectangular) {
    DollarBlueWidget()
} timeline: {
    SimpleEntry(date: .now, dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel(nombre: "Contado con liquidación", compra: 1000, venta: 1000, fechaActualizacion: "") )
}
