//
//  CustomTabBarView.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 17/10/2024.
//

import SwiftUI

struct CustomTabBarView: View {
    var activeForeground: Color = .white
    var activeBackground: Color = PremiumPalette.emerald

    @Binding var activeTab : TabModel
    @Namespace private var animation
    @State private var highlightedTab: TabModel = .home

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabModel.allCases, id: \.rawValue) { tab in
                Button {
                    guard activeTab != tab else { return }

                    activeTab = tab

                    withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                        highlightedTab = tab
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .frame(width: 30, height: 30)

                        if activeTab == tab {
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fixedSize(horizontal: true, vertical: false)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(activeTab == tab ? activeForeground : .primary.opacity(0.68))
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(.rect)
                    .background {
                        if highlightedTab == tab {
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
                                .matchedGeometryEffect(id: "ACTIVETBAR", in: animation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 45)
        .background(
            .background
                .opacity(0.4)
                .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                .shadow(.drop(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)),
            in: .capsule
        )
        .zIndex(50)
        .onAppear {
            highlightedTab = activeTab
        }
        .onChange(of: activeTab) { _, newValue in
            guard highlightedTab != newValue else { return }

            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                highlightedTab = newValue
            }
        }
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
