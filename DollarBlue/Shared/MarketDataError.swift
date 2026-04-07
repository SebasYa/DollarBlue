//
//  MarketDataError.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import Foundation
import DollarNetworkManage

struct AppAlertMessage: Identifiable, Equatable {
    let id = UUID()
    let value: String
}

enum DollarNetworkAppError: LocalizedError {
    case invalidResponse(statusCode: Int?)
    case transport(URLError)
    case decoding(DecodingError)
    case unexpected(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let statusCode):
            if let statusCode {
                switch statusCode {
                case 400:
                    return "La solicitud enviada a la API no fue valida."
                case 404:
                    return "El recurso solicitado no existe o no está disponible."
                case 429:
                    return "La API rechazó temporalmente la consulta por exceso de solicitudes."
                case 500...599:
                    return "La API está teniendo un problema interno. Intentalo nuevamente en unos minutos."
                default:
                    return "El servidor respondió con un estado invalido (\(statusCode))."
                }
            }

            return "La respuesta del servidor no fue valida."
        case .transport(let error):
            switch error.code {
            case .notConnectedToInternet:
                return "No hay conexión a internet."
            case .timedOut:
                return "La solicitud tardo demasiado. Intentalo nuevamente."
            case .networkConnectionLost, .cannotConnectToHost, .cannotFindHost:
                return "No se pudo conectar con el servidor."
            case .cannotDecodeRawData, .cannotParseResponse:
                return "La respuesta recibida no pudo procesarse."
            default:
                return "Ocurrió un error de red: \(error.localizedDescription)"
            }
        case .decoding:
            return "No se pudieron interpretar los datos recibidos."
        case .unexpected(let error):
            return "Ocurrió un error inesperado: \(error.localizedDescription)"
        }
    }

    static func from(_ error: Error) -> DollarNetworkAppError {
        guard let requestError = error as? MarketDataRequestError else {
            return .unexpected(error)
        }

        switch requestError {
        case .invalidResponse(let statusCode):
            return .invalidResponse(statusCode: statusCode)
        case .transport(let urlError):
            return .transport(urlError)
        case .decoding(let decodingError):
            return .decoding(decodingError)
        case .unexpected(let underlyingError):
            return .unexpected(underlyingError)
        }
    }
}
