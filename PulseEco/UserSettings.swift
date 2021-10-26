
import Foundation

class UserSettings: ObservableObject {
    
    private struct Keys {
        static let favouriteCities = "pulseco.favouriteCities"
        static let cityValues = "pulseeco.cityValues"
        static let selectedCity = "puseleco.selectedCity"
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
    
    static var selectedCity: City {
        set(value) {
            if let encoded = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(encoded, forKey: Keys.selectedCity)
            }
        }
        get {
            if let data = UserDefaults.standard.object(forKey: Keys.selectedCity) as? Data,
               let decoded = try? JSONDecoder().decode(City.self, from: data) {
                return decoded
            }
            return City.defaultCity()
        }
    }
    
    func removeFavouriteCity(_ city: City) {
        var fc = favouriteCities
        fc.removeAll { $0 == city }
        self.favouriteCities = fc
    }
    
    func addFavoriteCity(_ city: City) {
        var fc = favouriteCities
        fc.removeAll { $0 == city }
        fc.insert(city, at: 0)
        self.favouriteCities = fc
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
