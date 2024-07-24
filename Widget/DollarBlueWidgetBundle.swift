//
//  DollarBlueWidgetBundle.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import WidgetKit
import SwiftUI

@main
struct DollarBlueWidgetBundle: WidgetBundle {
    @Environment(\.colorScheme) var colorSheme: ColorScheme
    var body: some Widget {
        DollarBlueWidget()
    }
}
