//
//  DollarBlueApp.swift
//  DollarBlue
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

@main
struct DollarBlueApp: App {
    @State private var quoteStore = QuoteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(quoteStore)
        }
    }
}
