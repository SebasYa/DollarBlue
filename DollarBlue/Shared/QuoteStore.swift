//
//  QuoteStore.swift
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
final class QuoteStore {
    var quotes = [DollarInfoModel]()
    var dollarQuotes = [DolarAPIQuote]()
    var currencyQuotes = [DolarAPIQuote]()
    var alertMessage: AppAlertMessage?
    var connectionStatus = QuoteConnectionStatus.unknown
    var isLoading = false
    var isCurrenciesLoading = false
    var refreshRevision = 0
    var currencyRefreshRevision = 0
    var lastSuccessfulRefreshAt: Date?

    private let repository: MarketDataRepository
    private var hasLoadedOnce = false
    private var hasLoadedCurrenciesOnce = false

    init(repository: MarketDataRepository = .live) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard quotes.isEmpty, !hasLoadedOnce else {
            return
        }

        await refresh()
    }

    func refresh() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        connectionStatus = .checking

        defer {
            isLoading = false
        }

        do {
            let fetchedQuotes = try await repository.fetchCurrentDollarQuotes()
            dollarQuotes = fetchedQuotes
            quotes = fetchedQuotes.map(\.legacyDollarInfoModel)
            hasLoadedOnce = true
            refreshRevision += 1
            lastSuccessfulRefreshAt = .now
            alertMessage = nil
            connectionStatus = .stable(quotesCount: fetchedQuotes.count)
        } catch {
            let appError = DollarNetworkAppError.from(error)
            let message = appError.localizedDescription
            connectionStatus = .issue(message: message)
            alertMessage = AppAlertMessage(value: message)
        }
    }

    func refreshCurrencies() async {
        guard !isCurrenciesLoading else {
            return
        }

        isCurrenciesLoading = true

        defer {
            isCurrenciesLoading = false
        }

        do {
            currencyQuotes = try await repository.fetchCurrentCurrencyQuotes()
            hasLoadedCurrenciesOnce = true
            currencyRefreshRevision += 1
        } catch {
            alertMessage = AppAlertMessage(value: DollarNetworkAppError.from(error).localizedDescription)
        }
    }

    func loadCurrenciesIfNeeded() async {
        guard currencyQuotes.isEmpty, !hasLoadedCurrenciesOnce else {
            return
        }

        await refreshCurrencies()
    }

    func dismissAlert() {
        alertMessage = nil
    }
}
