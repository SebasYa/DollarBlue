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
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
            HStack(spacing: 6) {
                ForEach(TabModel.allCases, id: \.rawValue) { tab in
                    Button {
                        activeTab = tab
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 30, height: 30)
                            
                            if activeTab == tab {
                                Text(tab.title)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                        }
                        .foregroundStyle(activeTab == tab ? activeForeground : .primary.opacity(0.65))
                        .padding(.vertical, 8)
                        .padding(.leading, 12)
                        .padding(.trailing, 16)
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
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .premiumSurface(cornerRadius: 32, accent: PremiumPalette.emerald, glassEnabled: true)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: FloatingTabBarFramePreferenceKey.self,
                            value: proxy.frame(in: .named(FloatingTabBarLayout.coordinateSpaceName))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .zIndex(50)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }
}

#Preview {
    ContentView()
}
