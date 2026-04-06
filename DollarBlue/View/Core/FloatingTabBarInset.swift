//
//  FloatingTabBarInset.swift
//  DollarBlue
//
//  Created by Codex on 04/04/2026.
//

import SwiftUI

enum FloatingTabBarLayout {
    static let coordinateSpaceName = "FLOATING_TAB_BAR_CONTAINER"
    static let footerExtraPadding: CGFloat = 8
}

struct FloatingTabBarInsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nextValue = nextValue()
        value = max(value, nextValue)
    }
}

struct CustomTabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

private struct FloatingTabBarInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var floatingTabBarInset: CGFloat {
        get { self[FloatingTabBarInsetKey.self] }
        set { self[FloatingTabBarInsetKey.self] = newValue }
    }
}

struct FloatingTabBarFooterSpacer: View {
    @Environment(\.floatingTabBarInset) private var floatingTabBarInset

    var extraPadding: CGFloat = FloatingTabBarLayout.footerExtraPadding

    var body: some View {
        Color.clear
            .frame(height: max(0, floatingTabBarInset + extraPadding))
            //.allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
