//
//  Provider.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import Foundation
import WidgetKit
import SwiftUI


struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = ConfigurationAppIntent
    
    var dataController = DolarNetworkManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel.placeholderModel)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        await withCheckedContinuation { continuation in
            dataController.obtainAllCotizations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let filtaredDolarInfo1 = dataController.cotizaciones.first { $0.nombre == configuration.dollarInfo1.rawValue } ?? DollarInfoModel.placeholderModel
                let filtaredDolarInfo2 = dataController.cotizaciones.first { $0.nombre == configuration.dollarInfo2.rawValue } ?? DollarInfoModel.placeholderModel
                
                let entry = SimpleEntry(date: Date(), dolarInfo1: filtaredDolarInfo1, dolarInfo2: filtaredDolarInfo2)
                continuation.resume(returning: entry)
            }
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        await withCheckedContinuation  { continuation in
            
            dataController.obtainAllCotizations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let filtaredDolarInfo1 = dataController.cotizaciones.first { $0.nombre == configuration.dollarInfo1.rawValue } ?? DollarInfoModel.placeholderModel
                let filtaredDolarInfo2 = dataController.cotizaciones.first { $0.nombre == configuration.dollarInfo2.rawValue } ?? DollarInfoModel.placeholderModel
                
                var entries: [SimpleEntry] = []
                for hourOffset in 0 ..< 5 {
                    let currentDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: Date())!
                    let entry = SimpleEntry(date: currentDate, dolarInfo1: filtaredDolarInfo1, dolarInfo2: filtaredDolarInfo2)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                continuation.resume(returning: timeline)
            }
        }
    }
}
