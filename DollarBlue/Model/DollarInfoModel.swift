//
//  DollarInfoModel.swift
//  DollarBlue
//
//  Created by Sebastian Yanni on 24/07/2024.
//

import Foundation

struct DollarInfoModel: Codable{
    let nombre: String
    let compra: Double
    let venta: Double
    let fechaActualizacion: String
    
    static var placeholderModel: DollarInfoModel {
        return DollarInfoModel(nombre: "Oficial", compra: 980, venta: 988, fechaActualizacion: "03-02-1991")
    }
}
