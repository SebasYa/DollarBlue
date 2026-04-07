//
//  ExchangeCatalogStore.swift
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
final class ExchangeCatalogStore {
    var exchanges = [DolarAPIExchange]()
    var alertMessage: AppAlertMessage?
    var isLoading = false

    private let repository: MarketDataRepository
    private var hasLoadedOnce = false

    init(repository: MarketDataRepository = .live) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard exchanges.isEmpty, !hasLoadedOnce else {
            return
        }

        await refresh()
    }

    func refresh() async {
        guard !isLoading else {
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            exchanges = try await repository.fetchExchangeCatalog()
            hasLoadedOnce = true
            alertMessage = nil
        } catch {
            alertMessage = AppAlertMessage(value: DollarNetworkAppError.from(error).localizedDescription)
        }
    }

    func exchange(for id: String) -> DolarAPIExchange? {
        exchanges.first { $0.id == id }
    }

    func logoURL(for id: String) -> URL? {
        exchange(for: id)?.logoURL
    }
}
