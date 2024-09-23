//
//  DollarBlueApp.swift
//  DollarBlue
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI
import DollarNetworkManage

@main
struct DollarBlueApp: App {
    private var dataController = DollarNetworkManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
