import Foundation

enum AppView: String, Codable {
    case dashboard
    case mapView
    case settings
}

struct UserSettings {
    private struct Keys {
        static let favouriteCities = "pulseco.favouriteCities"
        static let cityValues = "pulseeco.cityValues"
        static let selectedCity = "puseleco.selectedCity"
    }
    
    private init() {
        
    }

    @UserDefaultsWrapper(key: Keys.favouriteCities, defaultValue: [], shouldCache: true)
    static var favouriteCities: [City]
    
    @UserDefaultsWrapper(key: Keys.cityValues, defaultValue: [], shouldCache: true)
    static var cityValues: [CityOverallValues]
    
    @UserDefaultsWrapper(key: Keys.selectedCity, defaultValue: City.defaultCity(), shouldCache: true)
    static var selectedCity: City

    static func removeFavouriteCity(_ city: City) {
        var favouriteCitiesCopy = favouriteCities
        favouriteCitiesCopy.removeAll { $0 == city }
        self.favouriteCities = favouriteCitiesCopy
    }

    static func addFavoriteCity(_ city: City) {
        var favouriteCitiesCopy = favouriteCities
        favouriteCitiesCopy.removeAll { $0 == city }
        favouriteCitiesCopy.insert(city, at: 0)
        self.favouriteCities = favouriteCitiesCopy
    }
}

