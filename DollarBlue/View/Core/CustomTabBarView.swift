//
//  CustomTabBarView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 17/10/2024.
//

import SwiftUI

struct CustomTabBarView: View {
    @Environment(\.colorScheme) private var colorScheme

    var activeForeground: Color = .white
    var activeBackground: Color = PremiumPalette.emerald

    @Binding var activeTab : TabModel
    @Namespace private var animation
    @State private var tabLocation: CGRect = .zero

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabModel.allCases, id: \.rawValue) { tab in
                Button {
                    activeTab = tab
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .frame(width: 30, height: 30)

                        if activeTab == tab {
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(activeTab == tab ? activeForeground : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(.rect)
                    .background {
                        if activeTab == tab {
                            Capsule()
                                .fill(Color.clear)
                                .onGeometryChange(for: CGRect.self, of: {
                                    $0.frame(in: .named("TABBARVIEW"))
                                }, action: { newValue in
                                    tabLocation = newValue
                                })
                                .matchedGeometryEffect(id: "ACTIVETBAR", in: animation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(alignment: .leading) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            activeBackground,
                            PremiumPalette.emeraldHighlight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: tabLocation.width, height: tabLocation.height)
                .offset(x: tabLocation.minX)
        }
        .coordinateSpace(.named("TABBARVIEW"))
        .padding(.horizontal, 5)
        .frame(height: 45)
        .background {
            tabBarBackground
        }
        .zIndex(50)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }

    @ViewBuilder
    private var tabBarBackground: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.72))
                .background {
                    Capsule()
                        .fill(activeBackground.opacity(colorScheme == .dark ? 0.18 : 0.10))
                }
                .glassEffect(
                    .regular.tint(activeBackground.opacity(colorScheme == .dark ? 0.22 : 0.12)),
                    in: .capsule
                )
                .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
        } else {
            fallbackBackground
        }
        #else
        fallbackBackground
        #endif
    }

    private var fallbackBackground: some View {
        Capsule()
            .fill(.background.opacity(0.4))
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 5, y: 5)
            .shadow(color: Color.black.opacity(0.06), radius: 5, x: -5, y: -5)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.14) : Color.white.opacity(0.45)
    }
}

#Preview {
    CustomTabBarPreviewContainer()
        .padding()
        .background(PremiumScreenBackground())
}

private struct CustomTabBarPreviewContainer: View {
    @State private var activeTab: TabModel = .home

    var body: some View {
        CustomTabBarView(activeTab: $activeTab)
    }
}
