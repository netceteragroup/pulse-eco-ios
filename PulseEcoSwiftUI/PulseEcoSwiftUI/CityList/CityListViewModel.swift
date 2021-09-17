
import Foundation

class CityListViewModel: ObservableObject {
    @Published var cities: [CityRowViewModel] = []
    @Published var cityModel: [City] = []
    @Published var searchText : String = ""
    var text: String {
        return searchText == "" ? Trema.text(for: "suggested") : Trema.text(for: "results")
    }
    @Published var countries = Set<String>()
    
    init(cities: [City]) {
        self.cityModel = cities
        for city in cities {
            self.cities.append(CityRowViewModel(cityName: city.cityName, siteName: city.siteName, countryName: city.countryName, countryCode: city.countryCode))
            self.countries.insert(city.countryName)
            }
    }
    func getCountries() -> [String]{
        return self.countries.sorted {
            $0 < $1
        }
    }
    func getCities() -> [CityRowViewModel]{
        return self.cities.sorted {
            $0.siteName < $1.siteName
        }
    }
}
