//
//  AppIntent.swift
//  Widget
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import Foundation
import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configurar Widget"
    
    @Parameter(title: "Change 1st Quote", default: .oficial)
    var dollarInfo1: DollarInfoEnum
    
    @Parameter(title: "Change 2nd Quote", default: .dolarBlue)
    var dollarInfo2: DollarInfoEnum
}

extension ConfigurationAppIntent {
    fileprivate static var dolarInfo1: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.dollarInfo1 = .oficial
        return intent
    }
    
    fileprivate static var dolarInfo2: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.dollarInfo2 = .dolarBlue
        return intent
    }
}
