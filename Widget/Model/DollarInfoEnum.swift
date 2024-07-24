//
//  DollarInfoEnum.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import Foundation
import AppIntents

enum DollarInfoEnum: String, CaseIterable, AppEnum {
    
    case oficial = "Oficial"
    case dolarBlue = "Blue"
    case bolsa = "Bolsa"
    case ccl = "Contado con liquidación"
    case mayorista = "Mayorista"
    case cripto = "Cripto"
    case tarjeta = "Tarjeta"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Dolar Info"
    }
    
    static var caseDisplayRepresentations: [Self : DisplayRepresentation] {
        [
        .oficial: DisplayRepresentation(title: "Oficial"),
        .dolarBlue: DisplayRepresentation(title: "Blue"),
        .bolsa: DisplayRepresentation(title: "Bolsa"),
        .ccl: DisplayRepresentation(title: "CCL"),
        .mayorista: DisplayRepresentation(title: "Mayorista"),
        .cripto: DisplayRepresentation(title: "Cripto"),
        .tarjeta: DisplayRepresentation(title: "Tarjeta")
        ]
    }
}
