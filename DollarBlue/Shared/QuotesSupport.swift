//
//  QuotesSupport.swift
//  DollarBlue
//
//  Created by Codex on 04/04/2026.
//

import Foundation
import DollarInfoModel

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

enum HistoricalChangeTrend: Equatable {
    case up
    case down
    case flat
    case unavailable
}

struct HistoricalValueChange: Equatable {
    let currentValue: Double
    let previousValue: Double?

    var difference: Double? {
        guard let previousValue else {
            return nil
        }

        return currentValue - previousValue
    }

    var absoluteDifference: Double? {
        difference.map(abs)
    }

    var trend: HistoricalChangeTrend {
        guard let difference else {
            return .unavailable
        }

        if difference > 0.0001 {
            return .up
        }

        if difference < -0.0001 {
            return .down
        }

        return .flat
    }
}

struct QuoteHistoricalComparison: Equatable {
    let house: DollarHouse
    let displayName: String
    let buy: HistoricalValueChange
    let sell: HistoricalValueChange
    let spread: HistoricalValueChange
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

    static func resolvedHouses(
        for quotes: [DollarInfoModel],
        currentQuotes: [DolarAPIQuote]
    ) -> [DollarHouse] {
        Array(
            Set(
                quotes.compactMap { resolvedHouse(for: $0, currentQuotes: currentQuotes) }
            )
        )
        .sorted { $0.title < $1.title }
    }

    static func resolvedHouse(
        for quote: DollarInfoModel,
        currentQuotes: [DolarAPIQuote]
    ) -> DollarHouse? {
        if let matchedQuote = currentQuotes.first(where: { currentQuote in
            let lhs = normalizedMarketName(currentQuote.nombre)
            let rhs = normalizedMarketName(quote.nombre)
            return lhs == rhs || lhs.contains(rhs) || rhs.contains(lhs)
        }) {
            return DollarHouse(rawValue: matchedQuote.casa.lowercased())
        }

        let normalizedQuote = normalizedMarketName(quote.nombre)
        switch normalizedQuote {
        case let value where value.contains("oficial"):
            return .oficial
        case let value where value.contains("blue"):
            return .blue
        case let value where value.contains("bolsa") || value.contains("mep"):
            return .bolsa
        case let value where value.contains("contadoconliqui") || value.contains("contadoconliquidacion"):
            return .contadoconliqui
        case let value where value.contains("cripto") || value.contains("crypto"):
            return .cripto
        case let value where value.contains("mayorista"):
            return .mayorista
        case let value where value.contains("tarjeta"):
            return .tarjeta
        case let value where value.contains("solidario"):
            return .solidario
        case let value where value.contains("turista"):
            return .turista
        default:
            return nil
        }
    }

    static func historicalComparisonsByQuoteName(
        displayedQuotes: [DollarInfoModel],
        currentQuotes: [DolarAPIQuote],
        comparisonsByHouse: [DollarHouse: QuoteHistoricalComparison]
    ) -> [String: QuoteHistoricalComparison] {
        Dictionary(uniqueKeysWithValues: displayedQuotes.compactMap { quote in
            guard
                let house = resolvedHouse(for: quote, currentQuotes: currentQuotes),
                let comparison = comparisonsByHouse[house]
            else {
                return nil
            }

            return (quote.nombre, comparison)
        })
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
