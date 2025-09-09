import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let appCode = "appCode"
        static let country = "country"
        static let city = "city"
        static let recentRoutes = "recentRoutes"
        static let onlyAccessibleBuses = "onlyAccessibleBuses"
    }
    
    private init() {
        if defaults.string(forKey: Keys.appCode) == nil {
            defaults.set(UUID().uuidString, forKey: Keys.appCode)
        }
    }
    
    var appCode: String {
        defaults.string(forKey: Keys.appCode) ?? "undefined"
    }
    
    var country: String {
        get { defaults.string(forKey: Keys.country) ?? "Казахстан" }
        set { defaults.set(newValue, forKey: Keys.country) }
    }
    
    var city: String {
        get { defaults.string(forKey: Keys.city) ?? "Алматы" }
        set { defaults.set(newValue, forKey: Keys.city) }
    }
    
    var recentRoutes: [String] {
        get { defaults.stringArray(forKey: Keys.recentRoutes) ?? [] }
        set { defaults.set(newValue, forKey: Keys.recentRoutes) }
    }
    
    var onlyAccessibleBuses: Bool {
        get { defaults.bool(forKey: Keys.onlyAccessibleBuses) }
        set { defaults.set(newValue, forKey: Keys.onlyAccessibleBuses) }
    }
}

