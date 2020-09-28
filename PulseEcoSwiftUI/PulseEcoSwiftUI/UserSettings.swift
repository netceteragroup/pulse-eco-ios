import Foundation

class UserSettings: ObservableObject {

    @Published var favoriteCities: Set<CityModel> = [] {
        didSet {
           if let encoded = try? JSONEncoder().encode(favoriteCities) {
               UserDefaults.standard.set(encoded, forKey: "favoriteCities")
           }
        }
    }
    
    @Published var cityValues: [CityOverallValues] = [] {
        didSet {
           if let encoded = try? JSONEncoder().encode(cityValues) {
               UserDefaults.standard.set(encoded, forKey: "CityValues")
           }
        }
    }
    
    init() {
        if let favoriteCitiesData = UserDefaults.standard.data(forKey: "favoriteCities") {
            self.favoriteCities = (try? JSONDecoder().decode(Set<CityModel>.self, from: favoriteCitiesData)) ?? []
        }
        if let cityValuesData = UserDefaults.standard.data(forKey: "CityValues") {
            self.cityValues = (try? JSONDecoder().decode([CityOverallValues].self, from: cityValuesData)) ?? []
        }
    }
}
