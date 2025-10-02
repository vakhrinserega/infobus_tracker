//
//  SettingsStorage.swift
//  Infobus Tracker
//
//  Created by Mag on 30.09.2025.
//

//
//  SettingsStorage.swift
//  Infobus Tracker
//
//  Created by Mag on 12.09.2025.
//

import Foundation

final class SettingsStorage {
    static let shared = SettingsStorage()
    private let defaults = UserDefaults.standard

    // MARK: - Keys
    private enum Keys {
        static let selectedCountryId = "selectedCountryId"
        static let selectedCityId = "selectedCityId"
        static let onlyAccessibleBuses = "onlyAccessibleBuses"
        static let recentRoutes = "recentRoutes"
        static let appCode = "appCode"
        // для кэша остановок
        static let cachedStations = "cachedStations"
        static let cachedCityId = "cachedCityId"
        //для кэша маршрутов
        static let cachedRoutes = "cachedRoutes"
        //для сохранения id маршрутов между страницами
        static let selectedRouteIds = "selectedRouteIds"

    }

    // MARK: - Properties

    var selectedCountryId: Int? {
        get {
            let value = defaults.integer(forKey: Keys.selectedCountryId)
            return value == 0 ? nil : value
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.selectedCountryId)
            } else {
                defaults.removeObject(forKey: Keys.selectedCountryId)
            }
        }
    }

    var selectedCityId: Int? {
        get {
            let value = defaults.integer(forKey: Keys.selectedCityId)
            return value == 0 ? nil : value
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.selectedCityId)
            } else {
                defaults.removeObject(forKey: Keys.selectedCityId)
            }
        }
    }

    var onlyAccessibleBuses: Bool {
        get { defaults.bool(forKey: Keys.onlyAccessibleBuses) }
        set { defaults.set(newValue, forKey: Keys.onlyAccessibleBuses) }
    }

    var recentRoutes: [String] {
        get { defaults.stringArray(forKey: Keys.recentRoutes) ?? [] }
        set { defaults.set(newValue, forKey: Keys.recentRoutes) }
    }

    var appCode: String {
        get {
            if let code = defaults.string(forKey: Keys.appCode) {
                return code
            } else {
                let newCode = UUID().uuidString.prefix(8).uppercased()
                defaults.set(newCode, forKey: Keys.appCode)
                return String(newCode)
            }
        }
        set {
            defaults.set(newValue, forKey: Keys.appCode)
        }
    }

    // MARK: - Helpers

    /// Если кода ещё нет — создаём
    func ensureAppCode() {
        _ = appCode
    }
    
    
    // для хранения кэша маршрутов для остановок

    var cachedStations: [Station] {
        get {
            guard let data = defaults.data(forKey: Keys.cachedStations) else { return [] }
            return (try? JSONDecoder().decode([Station].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.cachedStations)
            }
        }
    }

    var cachedCityId: Int? {
        get { defaults.integer(forKey: Keys.cachedCityId) }
        set { defaults.set(newValue, forKey: Keys.cachedCityId) }
    }
    
    // для кэша маршрутов

    var cachedRoutes: [Route] {
        get {
            guard let data = defaults.data(forKey: Keys.cachedRoutes) else { return [] }
            return (try? JSONDecoder().decode([Route].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.cachedRoutes)
            }
        }
    }
    
    var selectedRouteIds: [Int] {
        get { defaults.array(forKey: Keys.selectedRouteIds) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: Keys.selectedRouteIds) }
    }
    
}
