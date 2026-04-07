//
//  HistoricalDollarStore.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import Foundation
import Observation
import DollarInfoModel
import DollarNetworkManage

@MainActor
@Observable
final class HistoricalDollarStore {
    var historyByHouse = [DollarHouse: ArgentinaDatosHistoricalDollarQuote]()
    var comparisonsByHouse = [DollarHouse: QuoteHistoricalComparison]()
    var alertMessage: AppAlertMessage?
    var isLoading = false
    var refreshRevision = 0

    private let repository: MarketDataRepository
    private var unavailableHouses = Set<DollarHouse>()
    private var cachedReferenceDayKey: String?

    init(repository: MarketDataRepository = .live) {
        self.repository = repository
    }

    func loadComparisonsIfNeeded(using currentQuotes: [DolarAPIQuote], houses: [DollarHouse]) async {
        let houses = normalizedHouses(houses)
        refreshCacheIfNeeded()

        let missingHouses = houses.filter { house in
            historyByHouse[house] == nil && !unavailableHouses.contains(house)
        }

        if !missingHouses.isEmpty {
            await fetchHistoricalQuotes(for: missingHouses)
        }

        rebuildComparisons(using: currentQuotes, houses: houses)
    }

    func refreshComparisons(using currentQuotes: [DolarAPIQuote], houses: [DollarHouse]) async {
        let houses = normalizedHouses(houses)
        resetCache()
        await fetchHistoricalQuotes(for: houses)
        rebuildComparisons(using: currentQuotes, houses: houses)
    }

    private func fetchHistoricalQuotes(for houses: [DollarHouse]) async {
        guard !isLoading else {
            return
        }

        isLoading = true
        defer {
            isLoading = false
        }

        var lastErrorMessage: String?

        for house in houses {
            do {
                if let quote = try await previousHistoricalQuote(for: house) {
                    historyByHouse[house] = quote
                    unavailableHouses.remove(house)
                } else {
                    historyByHouse.removeValue(forKey: house)
                    unavailableHouses.insert(house)
                }
            } catch {
                if isMissingHistoryError(error) {
                    historyByHouse.removeValue(forKey: house)
                    unavailableHouses.insert(house)
                    continue
                }

                lastErrorMessage = DollarNetworkAppError.from(error).localizedDescription
            }
        }

        if let lastErrorMessage {
            alertMessage = AppAlertMessage(value: lastErrorMessage)
        } else {
            alertMessage = nil
        }
    }

    private func previousHistoricalQuote(for house: DollarHouse) async throws -> ArgentinaDatosHistoricalDollarQuote? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 1...5 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            do {
                let quote = try await repository.fetchHistoricalDollarQuote(for: house, on: targetDate)

                if quote.compra != nil || quote.venta != nil {
                    return quote
                }
            } catch {
                if isMissingHistoryError(error) {
                    continue
                }

                throw error
            }
        }

        return nil
    }

    private func rebuildComparisons(using currentQuotes: [DolarAPIQuote], houses: [DollarHouse]) {
        var rebuilt = [DollarHouse: QuoteHistoricalComparison]()

        for house in houses {
            guard let currentQuote = currentQuotes.first(where: { $0.casa.lowercased() == house.rawValue }) else {
                continue
            }

            let previousQuote = historyByHouse[house]

            rebuilt[house] = QuoteHistoricalComparison(
                house: house,
                displayName: currentQuote.nombre,
                buy: HistoricalValueChange(
                    currentValue: currentQuote.compra,
                    previousValue: previousQuote?.compra
                ),
                sell: HistoricalValueChange(
                    currentValue: currentQuote.venta,
                    previousValue: previousQuote?.venta
                ),
                spread: HistoricalValueChange(
                    currentValue: max(0, currentQuote.venta - currentQuote.compra),
                    previousValue: previousQuote?.spread
                )
            )
        }

        comparisonsByHouse = rebuilt
        refreshRevision += 1
    }

    private func refreshCacheIfNeeded() {
        let currentKey = Self.referenceDayKey(for: .now)
        guard cachedReferenceDayKey != currentKey else {
            return
        }

        cachedReferenceDayKey = currentKey
        historyByHouse.removeAll()
        comparisonsByHouse.removeAll()
        unavailableHouses.removeAll()
    }

    private func resetCache() {
        cachedReferenceDayKey = Self.referenceDayKey(for: .now)
        historyByHouse.removeAll()
        comparisonsByHouse.removeAll()
        unavailableHouses.removeAll()
    }

    private func normalizedHouses(_ houses: [DollarHouse]) -> [DollarHouse] {
        Array(Set(houses)).sorted { $0.title < $1.title }
    }

    private func isMissingHistoryError(_ error: Error) -> Bool {
        guard let requestError = error as? MarketDataRequestError else {
            return false
        }

        if case .invalidResponse(let statusCode) = requestError {
            return statusCode == 404
        }

        return false
    }

    private static func referenceDayKey(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let referenceDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        return requestDateFormatter.string(from: referenceDate)
    }

    private static let requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    func dismissAlert() {
        alertMessage = nil
    }
}
