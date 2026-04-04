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
import DollarInfoModel

struct WidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            mediumLayout
        case .accessoryRectangular:
            accessoryLayout
        default:
            smallLayout
        }
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading) {
            widgetHeader(showPortraits: true)

            VStack(spacing: 8) {
                mediumQuoteRow(entry.dolarInfo1)
                mediumQuoteRow(entry.dolarInfo2)
            }

            widgetFooter
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            widgetHeader(showPortraits: false)

            widgetCompactRow(entry.dolarInfo1)

            Divider()
                .overlay(PremiumPalette.emerald.opacity(0.58))

            widgetCompactRow(entry.dolarInfo2)
        }
        .padding(5)
    }

    private var accessoryLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dolar")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(PremiumPalette.graphite)
                .lineLimit(1)

            accessoryQuoteLine(entry.dolarInfo1)
            accessoryQuoteLine(entry.dolarInfo2)
        }
    }

    private func widgetHeader(showPortraits: Bool) -> some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 4) {
                if !showPortraits {
                    Text("Dolar")
                        .font(.system(size: showPortraits ? 14 : 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .foregroundStyle(PremiumPalette.sand.opacity(0.6))
                    
                    Text("Mercado ARG")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(PremiumPalette.sand.opacity(0.4))
                }
            }

            Spacer()

            if showPortraits {
                HStack {
                    Image("ImageFranklin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 28)
                        .padding(.trailing, 10)
                        .padding(.leading, -10)

                    Spacer()
                    Text("Dolar Blue").font(.system(size: showPortraits ? 14 : 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        //.minimumScaleFactor(0.9)
                        .foregroundStyle(PremiumPalette.sand.opacity(0.6))
                    Spacer()
                    Image("ImageRoca")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: 22, height: 28)
                        .padding(.trailing, 14)
                }
            } else {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .frame(width: 28, height: 28)
                    .background {
                        Circle()
                            .fill(PremiumPalette.emerald.opacity(0.16))
                    }
            }
        }
    }

    private var widgetFooter: some View {
        HStack(spacing: 8) {
            Spacer()
            Label("Act. \(premiumCompactMiniUpdateString(entry.dolarInfo1.fechaActualizacion))", systemImage: "clock")
                .font(.caption2)
                .foregroundStyle(PremiumPalette.cream.opacity(0.3))
                .lineLimit(1)
                .minimumScaleFactor(0.15)
        }
    }

    private func mediumQuoteRow(_ quote: DollarInfoModel) -> some View {
        HStack {
            Text(compactName(for: quote))
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(PremiumPalette.emeraldHighlight)

            HStack(spacing: 8) {
                mediumValueBlock(title: "Compra", value: quote.compra, accent: PremiumPalette.sand.opacity(0.75))
                mediumValueBlock(title: "Venta", value: quote.venta, accent: PremiumPalette.sand.opacity(0.75))
            }
            .padding(.leading, 40)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PremiumPalette.emerald.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
        }
    }

    private func mediumValueBlock(title: String, value: Double, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .foregroundStyle(PremiumPalette.cream)

            PremiumCurrencyValueText(
                value: value,
                accent: accent,
                integerSize: 16,
                centsSize: 11
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func widgetCompactRow(_ quote: DollarInfoModel) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text(compactName(for: quote))
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .foregroundStyle(PremiumPalette.cream.opacity(0.5))

            HStack {
                Text("C: \(premiumCompactValue(for: quote.compra))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
                
                //Spacer(minLength: 4)
                Divider()
                    .overlay(PremiumPalette.emerald.opacity(0.78))
                
                Text("V: \(premiumCompactValue(for: quote.venta))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
            }
        }
    }

    private func accessoryQuoteLine(_ quote: DollarInfoModel) -> some View {
        HStack(spacing: 6) {
            Text(compactAccessoryName(for: quote))
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("C \(premiumCompactValue(for: quote.compra))")
                    .bold()
                    .foregroundStyle(PremiumPalette.cream)
                Text("V \(premiumCompactValue(for: quote.venta))")
                    .bold()
                    .foregroundStyle(PremiumPalette.warmWhite)
            }
            .font(.caption2)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.70)
        }
    }

    private var trackedQuotesCount: Int {
        [entry.dolarInfo1.nombre, entry.dolarInfo2.nombre]
            .filter { !$0.isEmpty }
            .count
    }

    private func compactName(for quote: DollarInfoModel) -> String {
        QuotePresentationSupport.compactDisplayName(for: quote.nombre)
    }

    private func compactAccessoryName(for quote: DollarInfoModel) -> String {
        let name = compactName(for: quote)
        return name.count <= 8 ? name : String(name.prefix(7)) + "…"
    }

    private func premiumCompactValue(for value: Double) -> String {
        let parts = premiumCurrencyParts(value)
        return parts.main + parts.cents
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
