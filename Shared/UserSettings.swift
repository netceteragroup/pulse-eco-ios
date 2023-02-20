import Foundation

enum AppView: String, Codable {
    case dashboard
    case mapView
    case settings
}

class UserSettings: ObservableObject {
    private struct Keys {
        static let favouriteCities = "pulseco.favouriteCities"
        static let cityValues = "pulseeco.cityValues"
        static let selectedCity = "puseleco.selectedCity"
        static let selectedAppView = "puseleco.selectedAppView"
    }

    @Published var favouriteCities: [City] {
        didSet {
            if let encoded = try? JSONEncoder().encode(favouriteCities) {
                UserDefaults.standard.set(encoded, forKey: Keys.favouriteCities)
            }
        }
    }
    @Published var cityValues: [CityOverallValues] {
        didSet {
            if let encoded = try? JSONEncoder().encode(cityValues) {
                UserDefaults.standard.set(encoded, forKey: Keys.cityValues)
            }
        }
    }
    
    @UserDefaultsEnumWrapper(key: Keys.selectedAppView, defaultValue: AppView.dashboard)
    var selectedAppView: AppView

    static var selectedCity: City {
        get {
            if let data = UserDefaults.standard.object(forKey: Keys.selectedCity) as? Data,
               let decoded = try? JSONDecoder().decode(City.self, from: data) {
                return decoded
            }
            return City.defaultCity()
        }
        set( value) {
            if let encoded = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(encoded, forKey: Keys.selectedCity)
            }
        }
    }
    
    static var appLanguage: String {
        get {
            UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        }
        set (toLanguage) {
            UserDefaults.standard.set(toLanguage, forKey: "AppLanguage")
        }
    }

    func removeFavouriteCity(_ city: City) {
        var favouriteCitiesCopy = favouriteCities
        favouriteCitiesCopy.removeAll { $0 == city }
        self.favouriteCities = favouriteCitiesCopy
    }

    func addFavoriteCity(_ city: City) {
        var favouriteCitiesCopy = favouriteCities
        favouriteCitiesCopy.removeAll { $0 == city }
        favouriteCitiesCopy.insert(city, at: 0)
        self.favouriteCities = favouriteCitiesCopy
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Keys.favouriteCities),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.favouriteCities = decoded
        } else {
            self.favouriteCities = []
        }

        if let data = UserDefaults.standard.data(forKey: Keys.cityValues),
           let decoded = try? JSONDecoder().decode([CityOverallValues].self, from: data) {
            self.cityValues = decoded
        } else {
            self.cityValues = []
        }
    }
}

