import Foundation

enum AppView: String, Codable {
    case dashboard
    case mapView
    case settings
}

struct UserSettings {
    private struct Keys {
        static let favoriteCities = "pulseco.favouriteCities"
        static let selectedCity = "puseleco.selectedCity"
    }
    
    private init() {
        
    }

    @UserDefaultsWrapper(key: Keys.favoriteCities, defaultValue: [], shouldCache: true)
    static var favoriteCities: [City]
    
    @UserDefaultsWrapper(key: Keys.selectedCity, defaultValue: City.defaultCity(), shouldCache: true)
    static var selectedCity: City

    static func removeFavoriteCity(_ city: City) {
        var favoriteCitiesCopy = favoriteCities
        favoriteCitiesCopy.removeAll { $0 == city }
        self.favoriteCities = favoriteCitiesCopy
    }

    static func addFavoriteCity(_ city: City) {
        var favoriteCitiesCopy = favoriteCities
        favoriteCitiesCopy.removeAll { $0 == city }
        favoriteCitiesCopy.insert(city, at: 0)
        self.favoriteCities = favoriteCitiesCopy
    }
}

