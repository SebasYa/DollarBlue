//
//  TabModel.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 17/10/2024.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    
    case home = "house.fill"
    case calculator = "brain.fill"
    case exchange = "globe.americas"
    case configuration = "gear"
    
    var title: String {
        switch self {
        case .home:
            "Dolar"
        case .calculator:
            "Computo"
        case .exchange:
            "Exchange"
        case .configuration:
            "Ajustes"
        }
    }
}
