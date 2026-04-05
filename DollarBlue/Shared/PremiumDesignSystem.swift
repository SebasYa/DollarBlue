//
//  PremiumDesignSystem.swift
//  DollarBlue
//
//  Created by Codex on 04/04/2026.
//

import SwiftUI
import Foundation

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "Sistema"
        case .light:
            return "Claro"
        case .dark:
            return "Oscuro"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum PremiumPalette {
    static let emerald = Color(red: 0.11, green: 0.30, blue: 0.08)
    static let emeraldHighlight = Color(red: 0.28, green: 0.56, blue: 0.25)
    static let cream = Color(red: 0.95, green: 0.94, blue: 0.90)
    static let warmWhite = Color(red: 0.985, green: 0.975, blue: 0.955)
    static let ink = Color(red: 0.10, green: 0.11, blue: 0.12)
    static let graphite = Color(red: 0.16, green: 0.17, blue: 0.18)
    static let sand = Color(red: 0.81, green: 0.79, blue: 0.73)
}

enum PremiumFormatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let editableAmount: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    static let updateDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter
    }()

    static let checkDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    static let compactUpdateDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter
    }()

    static let isoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let isoStandard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let fallbackParsers: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "dd-MM-yyyy HH:mm:ss",
            "dd/MM/yyyy HH:mm:ss"
        ]

        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }
    }()
}

func premiumCurrencyString(_ value: Double) -> String {
    PremiumFormatters.currency.string(from: NSNumber(value: value)) ?? "$0,00"
}

func premiumEditableAmountString(_ value: Double) -> String {
    PremiumFormatters.editableAmount.string(from: NSNumber(value: value)) ?? "0"
}

func premiumPercentageString(_ value: Double) -> String {
    PremiumFormatters.percent.string(from: NSNumber(value: value / 100)) ?? "0,0%"
}

func premiumCompactUpdateString(_ rawValue: String) -> String {
    let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return "Sin dato"
    }

    guard let parsedDate = premiumParsedDate(trimmed) else {
        return trimmed
    }

    return PremiumFormatters.updateDisplay.string(from: parsedDate)
}

func premiumFormattedCheckTime(_ date: Date) -> String {
    PremiumFormatters.checkDisplay.string(from: date)
}

func premiumCompactMiniUpdateString(_ rawValue: String) -> String {
    let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return "Sin dato"
    }

    guard let parsedDate = premiumParsedDate(trimmed) else {
        return trimmed
    }

    return PremiumFormatters.compactUpdateDisplay.string(from: parsedDate)
}

func premiumCurrencyParts(_ value: Double) -> (main: String, cents: String) {
    let formatted = premiumCurrencyString(value)
    guard let separatorIndex = formatted.lastIndex(of: ",") else {
        return (formatted, "")
    }

    let main = String(formatted[..<separatorIndex])
    let cents = String(formatted[separatorIndex...])
    return (main, cents)
}

private func premiumParsedDate(_ rawValue: String) -> Date? {
    if let date = PremiumFormatters.isoFractional.date(from: rawValue) {
        return date
    }

    if let date = PremiumFormatters.isoStandard.date(from: rawValue) {
        return date
    }

    for formatter in PremiumFormatters.fallbackParsers {
        if let date = formatter.date(from: rawValue) {
            return date
        }
    }

    return nil
}

struct PremiumScreenBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: radialColors,
                center: .topTrailing,
                startRadius: 40,
                endRadius: 500
            )
            .blendMode(.plusLighter)

            LinearGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.04 : 0.32),
                    Color.clear,
                    PremiumPalette.emerald.opacity(colorScheme == .dark ? 0.18 : 0.09)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var backgroundColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.04, green: 0.08, blue: 0.06),
                Color(red: 0.07, green: 0.10, blue: 0.10),
                Color(red: 0.02, green: 0.03, blue: 0.04)
            ]
        }

        return [
            PremiumPalette.warmWhite,
            PremiumPalette.cream,
            Color(red: 0.90, green: 0.94, blue: 0.90)
        ]
    }

    private var radialColors: [Color] {
        if colorScheme == .dark {
            return [
                PremiumPalette.emeraldHighlight.opacity(0.18),
                Color.clear
            ]
        }

        return [
            PremiumPalette.emerald.opacity(0.12),
            Color.clear
        ]
    }
}

struct PremiumSectionHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(PremiumPalette.emerald)
                .tracking(1.4)

            Text(title)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct PremiumPill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(label)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(.primary.opacity(0.82))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(PremiumPalette.emerald.opacity(0.12))
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                }
        )
    }
}

struct PremiumMetricTile: View {
    let label: String
    let value: String
    var detail: String? = nil
    var icon: String? = nil
    var accent: Color = PremiumPalette.emerald
    var glassEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                }

                Text(label)
                    .font(.caption)
                    .tracking(1.0)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumSurface(cornerRadius: 24, accent: accent, glassEnabled: glassEnabled)
    }
}

struct PremiumCurrencyValueText: View {
    let value: Double
    var accent: Color = .primary
    var integerSize: CGFloat = 24
    var centsSize: CGFloat = 15
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        let parts = premiumCurrencyParts(value)

        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(parts.main)
                    .font(.system(size: integerSize, weight: .bold, design: .rounded))
                Text(parts.cents)
                    .font(.system(size: centsSize, weight: .semibold, design: .rounded))
                    .baselineOffset(1)
            }
            .monospacedDigit()
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.62)

            VStack(alignment: alignment, spacing: 0) {
                Text(parts.main)
                    .font(.system(size: max(15, integerSize - 4), weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.52)
                Text(parts.cents.isEmpty ? ",00" : parts.cents)
                    .font(.system(size: max(12, centsSize), weight: .semibold, design: .rounded))
            }
            .monospacedDigit()
            .foregroundStyle(accent)
        }
    }
}

struct PremiumWidgetBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.14, blue: 0.12),
                    Color(red: 0.06, green: 0.08, blue: 0.08),
                    Color.black.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    PremiumPalette.emerald.opacity(0.26),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 180
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear,
                    PremiumPalette.emeraldHighlight.opacity(0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

extension View {
    func premiumSurface(
        cornerRadius: CGFloat = 26,
        accent: Color = PremiumPalette.emerald,
        glassEnabled: Bool = false
    ) -> some View {
        modifier(
            PremiumSurfaceModifier(
                cornerRadius: cornerRadius,
                accent: accent,
                glassEnabled: glassEnabled
            )
        )
    }
}

private struct PremiumSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat
    let accent: Color
    let glassEnabled: Bool

    func body(content: Content) -> some View {
        content
            .background {
                surfaceBackground
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: 22, x: 0, y: 12)
    }

    @ViewBuilder
    private var surfaceBackground: some View {
        #if os(iOS)
        if glassEnabled {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.78))
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(accent.opacity(colorScheme == .dark ? 0.18 : 0.12))
                    }
                    .glassEffect(
                        .regular.tint(accent.opacity(colorScheme == .dark ? 0.24 : 0.14)),
                        in: .rect(cornerRadius: cornerRadius)
                    )
            } else {
                fallbackBackground
            }
        } else {
            fallbackBackground
        }
        #else
        fallbackBackground
        #endif
    }

    @ViewBuilder
    private var fallbackBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(accent.opacity(colorScheme == .dark ? 0.12 : 0.08))
            }
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.14) : Color.white.opacity(0.55)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.28) : PremiumPalette.ink.opacity(0.10)
    }
}
