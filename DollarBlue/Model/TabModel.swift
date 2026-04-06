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
    case configuration = "gear"
    
    var title: String {
        switch self {
        case .home:
            "Mercado"
        case .calculator:
            "Calcu"
        case .configuration:
            "Ajustes"
        }
    }
}
