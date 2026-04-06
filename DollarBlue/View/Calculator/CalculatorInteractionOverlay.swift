//
//  CalculatorInteractionOverlay.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import SwiftUI

enum CalculatorLayout {
    static let coordinateSpaceName = "CALCULATOR_LAYOUT"
}

struct CalculatorAmountFieldFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let nextValue = nextValue()
        if nextValue != .zero {
            value = nextValue
        }
    }
}

struct CalculatorDismissOverlay: View {
    let focusFrame: CGRect
    let onCancel: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let container = proxy.frame(in: .local)
            let safeFocusFrame = focusFrame.intersection(container)

            VStack(spacing: 0) {
                CancelTapRegion(
                    width: container.width,
                    height: max(0, safeFocusFrame.minY),
                    onCancel: onCancel
                )

                HStack(spacing: 0) {
                    CancelTapRegion(
                        width: max(0, safeFocusFrame.minX),
                        height: safeFocusFrame.height,
                        onCancel: onCancel
                    )

                    Color.clear
                        .frame(width: safeFocusFrame.width, height: safeFocusFrame.height)
                        .allowsHitTesting(false)

                    CancelTapRegion(
                        width: max(0, container.width - safeFocusFrame.maxX),
                        height: safeFocusFrame.height,
                        onCancel: onCancel
                    )
                }

                CancelTapRegion(
                    width: container.width,
                    height: max(0, container.height - safeFocusFrame.maxY),
                    onCancel: onCancel
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

private struct CancelTapRegion: View {
    let width: CGFloat
    let height: CGFloat
    let onCancel: () -> Void

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .onTapGesture(perform: onCancel)
    }
}
