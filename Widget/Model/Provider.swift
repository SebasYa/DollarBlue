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
import DollarInfoModel
import DollarNetworkManage


struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = ConfigurationAppIntent

    private let marketWindow = WidgetMarketWindow(
        openingHour: 10,
        closingHour: 15,
        refreshIntervalMinutes: 30
    )
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dolarInfo1: DollarInfoModel.placeholderModel, dolarInfo2: DollarInfoModel.placeholderModel)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let quotes = (try? await DollarNetworkManager.fetchAllCotizations()) ?? []
        return makeEntry(for: configuration, quotes: quotes, date: .now)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let now = Date()
        let nextReloadDate = marketWindow.nextReloadDate(after: now)

        do {
            let quotes = try await DollarNetworkManager.fetchAllCotizations()
            let entry = makeEntry(for: configuration, quotes: quotes, date: now)
            return Timeline(entries: [entry], policy: .after(nextReloadDate))
        } catch {
            let fallbackEntry = makeEntry(for: configuration, quotes: [], date: now)
            return Timeline(entries: [fallbackEntry], policy: .after(nextReloadDate))
        }
    }

    private func makeEntry(for configuration: ConfigurationAppIntent, quotes: [DollarInfoModel], date: Date) -> SimpleEntry {
        let filteredDolarInfo1 = quotes.first { $0.nombre == configuration.dollarInfo1.rawValue } ?? DollarInfoModel.placeholderModel
        let filteredDolarInfo2 = quotes.first { $0.nombre == configuration.dollarInfo2.rawValue } ?? DollarInfoModel.placeholderModel

        return SimpleEntry(date: date, dolarInfo1: filteredDolarInfo1, dolarInfo2: filteredDolarInfo2)
    }
}

private struct WidgetMarketWindow {
    let openingHour: Int
    let closingHour: Int
    let refreshIntervalMinutes: Int

    func nextReloadDate(after date: Date, calendar: Calendar = .current) -> Date {
        let openingToday = marketBoundary(for: date, hour: openingHour, calendar: calendar)
        let closingToday = marketBoundary(for: date, hour: closingHour, calendar: calendar)

        if date < openingToday {
            return openingToday
        }

        if date >= closingToday {
            return nextOpening(after: date, calendar: calendar)
        }

        let nextSlot = nextHalfHourSlot(after: date, calendar: calendar)
        if nextSlot <= closingToday {
            return nextSlot
        }

        return nextOpening(after: date, calendar: calendar)
    }

    private func nextHalfHourSlot(after date: Date, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let currentMinute = components.minute ?? 0
        let roundedMinute = ((currentMinute / refreshIntervalMinutes) + 1) * refreshIntervalMinutes

        if roundedMinute >= 60 {
            components.hour = (components.hour ?? 0) + 1
            components.minute = 0
        } else {
            components.minute = roundedMinute
        }

        components.second = 0
        return calendar.date(from: components) ?? date.addingTimeInterval(TimeInterval(refreshIntervalMinutes * 60))
    }

    private func nextOpening(after date: Date, calendar: Calendar) -> Date {
        let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        return marketBoundary(for: nextDay, hour: openingHour, calendar: calendar)
    }

    private func marketBoundary(for date: Date, hour: Int, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: calendar.date(from: components) ?? date) ?? date
    }
}
