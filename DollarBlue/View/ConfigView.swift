//
//  ConfigView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct ConfigView: View {
    @AppStorage("themePreference") private var themePreference = AppThemeMode.system.rawValue
    @AppStorage("showPortraitHeader") private var showPortraitHeader = true
    @AppStorage("useCompactCards") private var useCompactCards = false
    @AppStorage("showUpdateStamp") private var showUpdateStamp = true
    @AppStorage("quoteSortOrder") private var quoteSortOrder = QuoteSortOrder.api.rawValue
    @AppStorage("featuredMarketPrimary") private var featuredMarketPrimary = QuotePresentationSupport.defaultPrimaryMarketID
    @AppStorage("featuredMarketSecondary") private var featuredMarketSecondary = QuotePresentationSupport.defaultSecondaryMarketID
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumSectionHeader(
                        eyebrow: "Personalizacion",
                        title: "Ajustes",
                        subtitle: "Una mezcla entre lectura financiera sobria y una capa visual mas nativa para iOS."
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Tema")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: 10) {
                            ForEach(AppThemeMode.allCases) { mode in
                                Button {
                                    themePreference = mode.rawValue
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
                        .padding(8)
                        .premiumSurface(cornerRadius: 22, accent: PremiumPalette.emerald, glassEnabled: true)
                    }
                    .padding(20)
                    .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald, glassEnabled: true)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Experiencia")
                            .font(.headline)

                        settingsToggle(
                            icon: "person.crop.rectangle",
                            title: "Mostrar retratos en el encabezado",
                            subtitle: "Mantiene el guiño visual premium en Home.",
                            isOn: $showPortraitHeader
                        )

                        settingsToggle(
                            icon: "rectangle.compress.vertical",
                            title: "Usar tarjetas compactas",
                            subtitle: "Hace que Home y Calculadora respiren menos y muestren mas contenido.",
                            isOn: $useCompactCards
                        )

                        settingsToggle(
                            icon: "clock.arrow.circlepath",
                            title: "Mostrar sello de actualizacion",
                            subtitle: "Enseña la fecha de referencia dentro de las tarjetas y del header principal.",
                            isOn: $showUpdateStamp
                        )
                    }
                    .padding(20)
                    .premiumSurface(cornerRadius: 28, accent: PremiumPalette.emerald.opacity(0.9), glassEnabled: true)

                    marketConfigurationSection

                    previewSection

                    FloatingTabBarFooterSpacer(extraPadding: 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }
            .background(PremiumScreenBackground())
        }
    }

    private var selectedTheme: AppThemeMode {
        AppThemeMode(rawValue: themePreference) ?? .system
    }

    private var selectedSortOrder: QuoteSortOrder {
        QuoteSortOrder(rawValue: quoteSortOrder) ?? .api
    }

    private var marketConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mercado")
                .font(.headline)

            Text("Ordena el listado principal y elige los dos mercados que queres ver destacados arriba.")
                .font(.caption)
                .foregroundStyle(.secondary)

            settingsMenuRow(
                icon: "arrow.up.arrow.down",
                title: "Ordenar referencias",
                value: selectedSortOrder.title
            ) {
                ForEach(QuoteSortOrder.allCases) { order in
                    Button(order.title) {
                        quoteSortOrder = order.rawValue
                    }
                }
            }

            settingsMenuRow(
                icon: "star.leadinghalf.filled",
                title: "Destacado principal",
                value: QuotePresentationSupport.marketTitle(for: featuredMarketPrimary)
            ) {
                ForEach(QuotePresentationSupport.featuredMarkets) { market in
                    Button(market.title) {
                        updatePrimaryMarket(market.id)
                    }
                }
            }

            settingsMenuRow(
                icon: "star",
                title: "Destacado secundario",
                value: QuotePresentationSupport.marketTitle(for: featuredMarketSecondary)
            ) {
                ForEach(QuotePresentationSupport.featuredMarkets) { market in
                    Button(market.title) {
                        updateSecondaryMarket(market.id)
                    }
                }
            }
        }
        .padding(20)
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.sand, glassEnabled: true)
    }

    private var previewSection: some View {
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
                    previewValueBlock(title: "Compra", value: "$1.210,00", accent: .secondary)
                    previewValueBlock(title: "Venta", value: "$1.230,00", accent: PremiumPalette.emeraldHighlight)
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
        .premiumSurface(cornerRadius: 28, accent: PremiumPalette.sand, glassEnabled: true)
    }

    private var previewPills: some View {
        Group {
            PremiumPill(icon: "circle.lefthalf.filled", label: selectedTheme.title)
            PremiumPill(icon: "rectangle.grid.1x2", label: useCompactCards ? "Compactas" : "Amplias")
            PremiumPill(icon: "clock.arrow.circlepath", label: showUpdateStamp ? "Con sello" : "Sin sello")
            PremiumPill(icon: "star.fill", label: QuotePresentationSupport.marketTitle(for: featuredMarketSecondary))
        }
    }

    private func settingsToggle(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PremiumPalette.emeraldHighlight)
                .frame(width: 34, height: 34)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PremiumPalette.emerald.opacity(0.10))
                }

            Toggle(isOn: isOn) {
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

    private func settingsMenuRow<Content: View>(
        icon: String,
        title: String,
        value: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
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

    private func updatePrimaryMarket(_ newMarketID: String) {
        let previousPrimary = featuredMarketPrimary
        featuredMarketPrimary = newMarketID

        if featuredMarketSecondary == newMarketID {
            featuredMarketSecondary = previousPrimary
        }
    }

    private func updateSecondaryMarket(_ newMarketID: String) {
        let previousSecondary = featuredMarketSecondary
        featuredMarketSecondary = newMarketID

        if featuredMarketPrimary == newMarketID {
            featuredMarketPrimary = previousSecondary
        }
    }

    private func previewValueBlock(title: String, value: String, accent: Color) -> some View {
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

#Preview {
    ConfigView()
}
