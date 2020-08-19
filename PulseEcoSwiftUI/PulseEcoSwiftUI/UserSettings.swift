
import Foundation

class UserSettings: ObservableObject {
    @Published var favouriteCities: Set<CityModel> {
        didSet {
           save()
        }
    }
    @Published var cityValues: [CityOverallValues] {
        didSet {
           saveValues()
        }
    }
    init() {
        if let data = UserDefaults.standard.data(forKey: "FavouriteCities") {
            if let decoded = try? JSONDecoder().decode(Set<CityModel>.self, from: data) {
                self.favouriteCities = decoded
                //return
            } else {
                self.favouriteCities = []
            }
        } else {
            self.favouriteCities = []
        }
        if let data = UserDefaults.standard.data(forKey: "CityValues") {
            if let decoded = try? JSONDecoder().decode([CityOverallValues].self, from: data) {
                self.cityValues = decoded
             //   return
            } else {
                 self.cityValues = []
            }
        } else {
            self.cityValues = []
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(favouriteCities) {
            UserDefaults.standard.set(encoded, forKey: "FavouriteCities")
        }
    }
    func saveValues() {
        if let encoded = try? JSONEncoder().encode(cityValues) {
            UserDefaults.standard.set(encoded, forKey: "CityValues")
        }
    }
}
