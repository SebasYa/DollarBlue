//
//  HomeComponents.swift
//  DollarBlue
//
//  Created by Codex on 05/04/2026.
//

import SwiftUI
import DollarInfoModel

struct HomeMarketPulseItem: Identifiable, Equatable {
    let id: String
    let label: String
    let value: String
    let detail: String
    let icon: String
    let accent: Color
}

struct MarketSummaryCard: View {
    let dolarInfo: DollarInfoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dolarInfo.nombre.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.1)
                .foregroundStyle(PremiumPalette.emerald)

            VStack(alignment: .leading, spacing: 6) {
                Label("Compra", systemImage: "arrow.down.left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PremiumCurrencyValueText(
                    value: dolarInfo.compra,
                    accent: .primary,
                    integerSize: 24,
                    centsSize: 15
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Label("Venta", systemImage: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PremiumCurrencyValueText(
                    value: dolarInfo.venta,
                    accent: PremiumPalette.emeraldHighlight,
                    integerSize: 20,
                    centsSize: 14
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 26, accent: PremiumPalette.emerald, glassEnabled: false)
    }
}

struct HomeHeroArt: View {
    let status: QuoteConnectionStatus
    let isChecking: Bool
    let action: () -> Void

    private var statusColor: Color {
        switch status.state {
        case .stable:
            return PremiumPalette.emeraldHighlight
        case .checking:
            return PremiumPalette.sand
        case .issue:
            return .red
        case .unknown:
            return .gray
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: -18) {
                    Image("ImageFranklin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 64)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)

                    Image("ImageRoca")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: 54, height: 66)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                }

                Circle()
                    .fill(statusColor)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    }
                    .overlay {
                        if isChecking {
                            ProgressView()
                                .scaleEffect(0.45)
                                .tint(.white)
                        }
                    }
                    .offset(x: 2, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .premiumSurface(cornerRadius: 26, accent: PremiumPalette.emerald, glassEnabled: true)
        }
        .buttonStyle(.plain)
    }
}

struct ConnectionStatusPopoverCard: View {
    let status: QuoteConnectionStatus

    private var accent: Color {
        switch status.state {
        case .stable:
            return PremiumPalette.emeraldHighlight
        case .checking:
            return PremiumPalette.sand
        case .issue:
            return .red
        case .unknown:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(accent)
                    .frame(width: 12, height: 12)

                Text(status.title)
                    .font(.headline)
            }

            Text(status.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Chequeado a las \(premiumFormattedCheckTime(status.checkedAt))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 260, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: accent, glassEnabled: true)
    }
}

struct HomeLoadingStateCard: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(PremiumPalette.emeraldHighlight)
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.emerald, glassEnabled: false)
    }
}

struct HomeEmptyStateCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumSurface(cornerRadius: 24, accent: PremiumPalette.sand, glassEnabled: false)
    }
}
