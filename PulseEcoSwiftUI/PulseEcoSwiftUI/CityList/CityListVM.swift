
import Foundation

class CityListVM: ObservableObject {
    @Published var cities: [CityRowVM] = []
    @Published var cityModel: [CityModel] = []
    @Published var searchText : String = ""
    var text: String {
        return searchText == "" ? Trema.text(for: "suggested", lang: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en") : Trema.text(for: "results", lang: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")
    }
    @Published var countries = Set<String>()
    
    init(cities: [CityModel]) {
        self.cityModel = cities
        for city in cities {
            self.cities.append(CityRowVM(cityName: city.cityName, siteName: city.siteName, countryName: city.countryName, countryCode: city.countryCode))
            self.countries.insert(city.countryName)
            }
    }
    func getCountries() -> [String]{
        return self.countries.sorted {
            $0 < $1
        }
    }
    func getCities() -> [CityRowVM]{
        return self.cities.sorted {
            $0.siteName < $1.siteName
        }
    }
}
