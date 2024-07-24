//
//  DollarBlueWidget.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import WidgetKit
import SwiftUI
import Foundation


struct DollarBlueWidget: Widget {
    let kind: String = "Dollar Blue Widget"
    let dataController = DolarNetworkManager()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(dataController: dataController)) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .configurationDisplayName("Dollar Blue Widget")
        .description("Muestra las cotizaciónes del dólar.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview("Medium", as: .systemMedium) {
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
