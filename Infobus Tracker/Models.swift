//
//  Models.swift
//  Infobus Tracker
//
//  Created by Mag on 12.09.2025.
//

import Foundation

// MARK: - Countries

/// Структура для запроса: http://infobus.kz/api/countries
struct Country: Codable {
    let id: Int
    let code: String
    let name: String
}

// MARK: - Cities

/// Короткая информация о городе (из /countries/{id}/cities)
struct CityShort: Codable {
    let id: Int
    let name: String
    let serviceURL: String
}

/// Подробная информация о городе (из /cities/{id})
struct CityDetail: Codable {
    let id: Int
    let name: String
    let lat: Double
    let lon: Double
    let mapZoom: Int
    let mapLayers: [String]
    let message: String
    let displayMessage: Bool
}

// MARK: - Routes

/// Маршрут (из /cities/{id}/routes)
struct Route: Codable {
    let id: Int
    let cityId: Int
    let busreportRouteId: Int
    let routeName: String
    let routeNumber: String
    let location: String
    let bussesOnRoute: Int
}

// MARK: - Stations

/// Остановка (из /cities/{id}/stations)
struct Station: Codable {
    let cityId: Int
    let id: Int
    let name: String
    let description: String
    let lat: Double
    let lon: Double
}

/// Связь маршрут ↔ остановка (из /cities/{id}/routestations)
struct RouteStation: Codable {
    let id: Int
    let cityId: Int
    let routeId: Int
    let stationId: Int
    let sequenceNumber: Int
    let directionForward: Bool
}

/// Подробная информация о станции маршрута (из /cities/{id}/routes/{routeId}/stations)
struct RouteStationDetail: Codable {
    let id: Int
    let routeId: Int
    let lat: Double
    let lon: Double
    let name: String
    let sequenceNumber: Int
    let directionForward: Bool
}

// MARK: - Buses

/// Автобус (из /cities/{id}/routes/{routeId}/busses)
struct Bus: Codable {
    let id: Int64
    let cityId: Int
    let busreportRouteId: Int
    let imei: String
    let name: String
    let direction: Int
    let speed: Int
    let lat: Double
    let lon: Double
    let invalidAdapted: Bool
    let offline: Bool
    let filling: Filling?
    
    struct Filling: Codable {
        let capacity: Int
        let filling: Int
        let percentage: Int
        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case capacity, filling, percentage
            case updatedAt = "updated_at"
        }
    }
}

// MARK: - Routes at station

/// Просто список маршрутов на остановке
/// (из /cities/{id}/stations/{stationId}/routesatstation)
typealias RoutesAtStation = [Int]

// MARK: - Predictions

/// Прогноз прибытия автобусов (из /cities/{id}/stations/{stationId}/prediction)
struct Prediction: Codable {
    let avgSpeed: Int
    let busIMEI: String
    let distance: Int
    let generatedTime: Int64   // Unix time в миллисекундах
    let mainPrediction: Bool
    let messageTime: Int64
    let prediction: Int        // в секундах
    let reverse: Bool
    let routeId: Int
    let speed: Int
    let stationId: Int
}

extension Prediction {
    var generatedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(generatedTime) / 1000)
    }
    
    var messageDate: Date {
        Date(timeIntervalSince1970: TimeInterval(messageTime) / 1000)
    }
}

