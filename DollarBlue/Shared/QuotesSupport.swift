//
//  QuotesSupport.swift
//  DollarBlue
//
//  Created by Codex on 04/04/2026.
//

import Foundation
import Observation
import DollarInfoModel
import DollarNetworkManage

struct AppAlertMessage: Identifiable, Equatable {
    let id = UUID()
    let value: String
}

enum DollarNetworkAppError: LocalizedError {
    case invalidResponse(statusCode: Int?)
    case transport(URLError)
    case decoding(DecodingError)
    case unexpected(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let statusCode):
            if let statusCode {
                return "El servidor respondió con un estado invalido (\(statusCode))."
            }

            return "La respuesta del servidor no fue valida."
        case .transport(let error):
            switch error.code {
            case .notConnectedToInternet:
                return "No hay conexión a internet."
            case .timedOut:
                return "La solicitud tardo demasiado. Intentalo nuevamente."
            case .networkConnectionLost, .cannotConnectToHost, .cannotFindHost:
                return "No se pudo conectar con el servidor."
            default:
                return "Ocurrió un error de red: \(error.localizedDescription)"
            }
        case .decoding:
            return "No se pudieron interpretar las cotizaciones recibidas."
        case .unexpected(let error):
            return "Ocurrió un error inesperado: \(error.localizedDescription)"
        }
    }

    static func from(_ error: Error) -> DollarNetworkAppError {
        guard let fetchError = error as? DollarNetworkManager.FetchError else {
            return .unexpected(error)
        }

        switch fetchError {
        case .invalidResponse(let statusCode):
            return .invalidResponse(statusCode: statusCode)
        case .transport(let urlError):
            return .transport(urlError)
        case .decoding(let decodingError):
            return .decoding(decodingError)
        case .unexpected(let underlyingError):
            return .unexpected(underlyingError)
        }
    }
}

enum QuoteSortOrder: String, CaseIterable, Identifiable {
    case api
    case name
    case highestBuy
    case highestSell
    case lowestBuy
    case lowestSell

    var id: String { rawValue }

    var title: String {
        switch self {
        case .api:
            return "Orden original"
        case .name:
            return "Nombre"
        case .highestBuy:
            return "Compra mayor"
        case .highestSell:
            return "Venta mayor"
        case .lowestBuy:
            return "Compra menor"
        case .lowestSell:
            return "Venta menor"
        }
    }
}

struct FeaturedQuoteMarket: Identifiable, Hashable {
    let id: String
    let title: String
    let aliases: [String]
}

struct QuoteConnectionStatus: Equatable {
    enum State: Equatable {
        case unknown
        case checking
        case stable
        case issue
    }

    let state: State
    let title: String
    let message: String
    let checkedAt: Date
}

struct QuoteDashboardMetrics {
    let averageBuy: Double
    let averageSell: Double
    let averageSpread: Double
    let highestSellQuote: DollarInfoModel?

    var highestSellValue: Double {
        highestSellQuote?.venta ?? 0
    }
}

struct HomeQuotePresentation {
    let displayedQuotes: [DollarInfoModel]
    let highlightedQuotes: [DollarInfoModel]
    let updateReference: String?
    let dashboardMetrics: QuoteDashboardMetrics

    static let empty = HomeQuotePresentation(
        displayedQuotes: [],
        highlightedQuotes: [],
        updateReference: nil,
        dashboardMetrics: QuoteDashboardMetrics(
            averageBuy: 0,
            averageSell: 0,
            averageSpread: 0,
            highestSellQuote: nil
        )
    )
}

extension QuoteConnectionStatus {
    static var unknown: QuoteConnectionStatus {
        QuoteConnectionStatus(
            state: .unknown,
            title: "Sin verificar",
            message: "Todavía no se consulto el estado del Servicio de Datos.",
            checkedAt: .now
        )
    }

    static var checking: QuoteConnectionStatus {
        QuoteConnectionStatus(
            state: .checking,
            title: "Verificando conexión",
            message: "Consultando el estado actual del Servicio de Datos.",
            checkedAt: .now
        )
    }

    static func stable(quotesCount: Int, checkedAt: Date = .now) -> QuoteConnectionStatus {
        QuoteConnectionStatus(
            state: .stable,
            title: "Valores al dia",
            message: "Datos actualizados a la fecha.",
            checkedAt: checkedAt
        )
    }

    static func issue(message: String, checkedAt: Date = .now) -> QuoteConnectionStatus {
        QuoteConnectionStatus(
            state: .issue,
            title: "Error",
            message: message,
            checkedAt: checkedAt
        )
    }
}

@MainActor
@Observable
final class QuoteStore {
    var quotes = [DollarInfoModel]()
    var alertMessage: AppAlertMessage?
    var connectionStatus = QuoteConnectionStatus.unknown
    var isLoading = false
    var refreshRevision = 0

    private var hasLoadedOnce = false

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
            let fetchedQuotes = try await DollarNetworkManager.fetchAllCotizations()
            quotes = fetchedQuotes
            hasLoadedOnce = true
            refreshRevision += 1
            alertMessage = nil
            connectionStatus = .stable(quotesCount: fetchedQuotes.count)
        } catch {
            let appError = DollarNetworkAppError.from(error)
            let message = appError.localizedDescription
            connectionStatus = .issue(message: message)
            alertMessage = AppAlertMessage(value: message)
        }
    }

    func dismissAlert() {
        alertMessage = nil
    }
}

enum QuotePresentationSupport {
    static let defaultPrimaryMarketID = "blue"
    static let defaultSecondaryMarketID = "oficial"

    static let featuredMarkets: [FeaturedQuoteMarket] = [
        FeaturedQuoteMarket(id: "blue", title: "Blue", aliases: ["blue"]),
        FeaturedQuoteMarket(id: "oficial", title: "Oficial", aliases: ["oficial"]),
        FeaturedQuoteMarket(id: "bolsa", title: "Bolsa", aliases: ["bolsa", "mep"]),
        FeaturedQuoteMarket(id: "ccl", title: "CCL", aliases: ["ccl", "contado con liqui", "contado con liquidacion", "contado con liquidación"]),
        FeaturedQuoteMarket(id: "tarjeta", title: "Tarjeta", aliases: ["tarjeta"]),
        FeaturedQuoteMarket(id: "mayorista", title: "Mayorista", aliases: ["mayorista"]),
        FeaturedQuoteMarket(id: "cripto", title: "Cripto", aliases: ["cripto", "crypto"])
    ]

    static func sortedQuotes(_ quotes: [DollarInfoModel], order: QuoteSortOrder) -> [DollarInfoModel] {
        switch order {
        case .api:
            return quotes
        case .name:
            return quotes.sorted {
                normalizedMarketName($0.nombre) < normalizedMarketName($1.nombre)
            }
        case .highestBuy:
            return quotes.sorted { lhs, rhs in
                if lhs.compra == rhs.compra {
                    return normalizedMarketName(lhs.nombre) < normalizedMarketName(rhs.nombre)
                }

                return lhs.compra > rhs.compra
            }
        case .highestSell:
            return quotes.sorted { lhs, rhs in
                if lhs.venta == rhs.venta {
                    return normalizedMarketName(lhs.nombre) < normalizedMarketName(rhs.nombre)
                }

                return lhs.venta > rhs.venta
            }
        case .lowestBuy:
            return quotes.sorted { lhs, rhs in
                if lhs.compra == rhs.compra {
                    return normalizedMarketName(lhs.nombre) < normalizedMarketName(rhs.nombre)
                }

                return lhs.compra < rhs.compra
            }
        case .lowestSell:
            return quotes.sorted { lhs, rhs in
                if lhs.venta == rhs.venta {
                    return normalizedMarketName(lhs.nombre) < normalizedMarketName(rhs.nombre)
                }

                return lhs.venta < rhs.venta
            }
        }
    }

    static func featuredQuotes(
        from quotes: [DollarInfoModel],
        primaryMarketID: String,
        secondaryMarketID: String
    ) -> [DollarInfoModel] {
        let marketIDs = [resolvedMarketID(primaryMarketID), resolvedMarketID(secondaryMarketID)]
        var result = [DollarInfoModel]()

        for marketID in marketIDs {
            guard let market = market(for: marketID) else {
                continue
            }

            if let quote = quotes.first(where: { matches($0.nombre, market: market) }), !result.contains(where: { $0.nombre == quote.nombre }) {
                result.append(quote)
            }
        }

        if result.isEmpty {
            return Array(quotes.prefix(2))
        }

        if result.count < 2 {
            let remaining = quotes.filter { quote in
                !result.contains(where: { $0.nombre == quote.nombre })
            }

            result.append(contentsOf: remaining.prefix(2 - result.count))
        }

        return result
    }

    static func marketTitle(for marketID: String) -> String {
        market(for: resolvedMarketID(marketID))?.title ?? "Sin seleccionar"
    }

    static func homePresentation(
        quotes: [DollarInfoModel],
        order: QuoteSortOrder,
        primaryMarketID: String,
        secondaryMarketID: String
    ) -> HomeQuotePresentation {
        let displayedQuotes = sortedQuotes(quotes, order: order)

        return HomeQuotePresentation(
            displayedQuotes: displayedQuotes,
            highlightedQuotes: featuredQuotes(
                from: displayedQuotes,
                primaryMarketID: primaryMarketID,
                secondaryMarketID: secondaryMarketID
            ),
            updateReference: displayedQuotes.first?.fechaActualizacion,
            dashboardMetrics: dashboardMetrics(from: displayedQuotes)
        )
    }

    static func dashboardMetrics(from quotes: [DollarInfoModel]) -> QuoteDashboardMetrics {
        guard !quotes.isEmpty else {
            return QuoteDashboardMetrics(
                averageBuy: 0,
                averageSell: 0,
                averageSpread: 0,
                highestSellQuote: nil
            )
        }

        let buyTotal = quotes.reduce(0) { $0 + $1.compra }
        let sellTotal = quotes.reduce(0) { $0 + $1.venta }
        let spreadTotal = quotes.reduce(0) { partial, quote in
            partial + max(0, quote.venta - quote.compra)
        }

        return QuoteDashboardMetrics(
            averageBuy: buyTotal / Double(quotes.count),
            averageSell: sellTotal / Double(quotes.count),
            averageSpread: spreadTotal / Double(quotes.count),
            highestSellQuote: quotes.max { lhs, rhs in
                lhs.venta < rhs.venta
            }
        )
    }

    static func compactDisplayName(for quoteName: String) -> String {
        let normalizedQuote = normalizedMarketName(quoteName)

        if let market = featuredMarkets.first(where: { matches(quoteName, market: $0) }) {
            return market.title
        }

        if normalizedQuote.hasPrefix("dolar") {
            let stripped = quoteName.replacingOccurrences(of: "Dolar ", with: "")
                .replacingOccurrences(of: "Dólar ", with: "")
            if stripped.count <= 14 {
                return stripped
            }
        }

        if quoteName.count <= 14 {
            return quoteName
        }

        return String(quoteName.prefix(13)) + "…"
    }

    static func resolvedMarketID(_ rawValue: String) -> String {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized.isEmpty ? defaultPrimaryMarketID : normalized
    }

    private static func market(for marketID: String) -> FeaturedQuoteMarket? {
        featuredMarkets.first { $0.id == marketID }
    }

    private static func matches(_ quoteName: String, market: FeaturedQuoteMarket) -> Bool {
        let normalizedQuote = normalizedMarketName(quoteName)
        return market.aliases.contains { alias in
            let normalizedAlias = normalizedMarketName(alias)
            return normalizedQuote == normalizedAlias || normalizedQuote.contains(normalizedAlias)
        }
    }

    private static func normalizedMarketName(_ rawValue: String) -> String {
        rawValue
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_AR"))
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }
}
