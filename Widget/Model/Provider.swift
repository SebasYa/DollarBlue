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
import DollarInfoModel
import DollarNetworkManage


struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = ConfigurationAppIntent
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel.placeholderModel)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let quotes = (try? await DollarNetworkManager.fetchAllCotizations()) ?? []
        return makeEntry(for: configuration, quotes: quotes, date: .now)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        do {
            let quotes = try await DollarNetworkManager.fetchAllCotizations()
            let entries = makeEntries(for: configuration, quotes: quotes)
            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            let retryDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
            let fallbackEntry = makeEntry(for: configuration, quotes: [], date: .now)
            return Timeline(entries: [fallbackEntry], policy: .after(retryDate))
        }
    }

    private func makeEntries(for configuration: ConfigurationAppIntent, quotes: [DollarInfoModel]) -> [SimpleEntry] {
        (0..<5).compactMap { hourOffset in
            guard let currentDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: .now) else {
                return nil
            }

            return makeEntry(for: configuration, quotes: quotes, date: currentDate)
        }
    }

    private func makeEntry(for configuration: ConfigurationAppIntent, quotes: [DollarInfoModel], date: Date) -> SimpleEntry {
        let filteredDolarInfo1 = quotes.first { $0.nombre == configuration.dollarInfo1.rawValue } ?? DollarInfoModel.placeholderModel
        let filteredDolarInfo2 = quotes.first { $0.nombre == configuration.dollarInfo2.rawValue } ?? DollarInfoModel.placeholderModel

        return SimpleEntry(date: date, dolarInfo1: filteredDolarInfo1, dolarInfo2: filteredDolarInfo2)
    }
}
