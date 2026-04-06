//
//  ConfigSections.swift
//  DollarBlue
//
//  Created by Codex on 05/04/2026.
//

import SwiftUI

struct ConfigThemeSection: View {
    let selectedTheme: AppThemeMode
    let selectTheme: (AppThemeMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tema")
                .font(.headline)
                .foregroundStyle(.primary)

            PremiumInteractiveGlassCluster(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Button {
                            selectTheme(mode)
                        } label: {
                            Text(mode.title)
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(selectedTheme == mode ? Color.white : .primary.opacity(0.82))
                                .background {
                                    Capsule()
                                        .fill(selectedTheme == mode ? PremiumPalette.emerald : Color.clear)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(8)
            .premiumSurface(cornerRadius: 22, accent: PremiumPalette.emerald, glassEnabled: true)
        }
        .padding(20)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald, glassEnabled: false)
    }
}

struct ConfigExperienceSection: View {
    @Binding var showPortraitHeader: Bool
    @Binding var useCompactCards: Bool
    @Binding var showUpdateStamp: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Experiencia")
                .font(.headline)

            SettingsToggleRow(
                icon: "person.crop.rectangle",
                title: "Mostrar retratos en el encabezado",
                subtitle: "Mantiene el guiño visual premium en Home.",
                isOn: $showPortraitHeader
            )

            SettingsToggleRow(
                icon: "rectangle.compress.vertical",
                title: "Usar tarjetas compactas",
                subtitle: "Hace que Home y Calculadora respiren menos y muestren mas contenido.",
                isOn: $useCompactCards
            )

            SettingsToggleRow(
                icon: "clock.arrow.circlepath",
                title: "Mostrar sello de actualizacion",
                subtitle: "Enseña la fecha de referencia dentro de las tarjetas y del header principal.",
                isOn: $showUpdateStamp
            )
        }
        .padding(20)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald.opacity(0.9), glassEnabled: false)
    }
}

struct ConfigMarketConfigurationSection: View {
    let selectedSortOrder: QuoteSortOrder
    let featuredMarketPrimary: String
    let featuredMarketSecondary: String
    let selectSortOrder: (QuoteSortOrder) -> Void
    let selectPrimaryMarket: (String) -> Void
    let selectSecondaryMarket: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mercado")
                .font(.headline)

            Text("Ordena el listado principal y elige los dos mercados que queres ver destacados arriba.")
                .font(.caption)
                .foregroundStyle(.secondary)

            SettingsMenuRow(
                icon: "arrow.up.arrow.down",
                title: "Ordenar referencias",
                value: selectedSortOrder.title
            ) {
                ForEach(QuoteSortOrder.allCases) { order in
                    Button(order.title) {
                        selectSortOrder(order)
                    }
                }
            }

            SettingsMenuRow(
                icon: "star.leadinghalf.filled",
                title: "Destacado principal",
                value: QuotePresentationSupport.marketTitle(for: featuredMarketPrimary)
            ) {
                ForEach(QuotePresentationSupport.featuredMarkets) { market in
                    Button(market.title) {
                        selectPrimaryMarket(market.id)
                    }
                }
            }

            SettingsMenuRow(
                icon: "star",
                title: "Destacado secundario",
                value: QuotePresentationSupport.marketTitle(for: featuredMarketSecondary)
            ) {
                ForEach(QuotePresentationSupport.featuredMarkets) { market in
                    Button(market.title) {
                        selectSecondaryMarket(market.id)
                    }
                }
            }
        }
        .padding(20)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.sand, glassEnabled: false)
    }
}

struct ConfigPreviewSection: View {
    let selectedTheme: AppThemeMode
    let useCompactCards: Bool
    let showUpdateStamp: Bool
    let featuredMarketPrimary: String
    let featuredMarketSecondary: String
    let selectedSortOrder: QuoteSortOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Vista previa")
                .font(.headline)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    previewPills
                }

                VStack(alignment: .leading, spacing: 10) {
                    previewPills
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(QuotePresentationSupport.marketTitle(for: featuredMarketPrimary))
                            .font(.system(.title3, design: .serif).weight(.semibold))
                        Text("\(useCompactCards ? "Tarjeta compacta" : "Tarjeta amplia") | \(selectedSortOrder.title)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "dollarsign.arrow.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PremiumPalette.emeraldHighlight)
                        .frame(width: 36, height: 36)
                        .background {
                            Circle()
                                .fill(PremiumPalette.emerald.opacity(0.14))
                        }
                }

                HStack(spacing: 10) {
                    PreviewValueBlock(title: "Compra", value: "$1.210,00", accent: .secondary)
                    PreviewValueBlock(title: "Venta", value: "$1.230,00", accent: PremiumPalette.emeraldHighlight)
                }

                if showUpdateStamp {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.caption.weight(.semibold))
                        Text("Referencia hoy 14:32")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(useCompactCards ? 16 : 18)
            .premiumSurface(cornerRadius: 24, accent: PremiumPalette.emerald, glassEnabled: false)
        }
        .padding(20)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.sand, glassEnabled: false)
    }

    private var previewPills: some View {
        Group {
            PremiumPill(icon: "circle.lefthalf.filled", label: selectedTheme.title)
            PremiumPill(icon: "rectangle.grid.1x2", label: useCompactCards ? "Compactas" : "Amplias")
            PremiumPill(icon: "clock.arrow.circlepath", label: showUpdateStamp ? "Con sello" : "Sin sello")
            PremiumPill(icon: "star.fill", label: QuotePresentationSupport.marketTitle(for: featuredMarketSecondary))
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PremiumPalette.emeraldHighlight)
                .frame(width: 34, height: 34)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PremiumPalette.emerald.opacity(0.10))
                }

            Toggle(isOn: $isOn) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .tint(PremiumPalette.emeraldHighlight)
        }
        .padding(.vertical, 6)
    }
}

struct SettingsMenuRow<Content: View>: View {
    let icon: String
    let title: String
    let value: String
    let content: () -> Content

    init(
        icon: String,
        title: String,
        value: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.content = content
    }

    var body: some View {
        Menu {
            content()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PremiumPalette.emeraldHighlight)
                    .frame(width: 34, height: 34)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(PremiumPalette.emerald.opacity(0.10))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(value)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

struct PreviewValueBlock: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PremiumPalette.emerald.opacity(0.08))
        }
    }
}
