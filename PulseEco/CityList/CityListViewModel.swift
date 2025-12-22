import Foundation
import Factory

class CityListViewModel: ObservableObject {
    @Injected(\.locationService) private var locationService
    @Injected(\.appData) private var appData
    @Injected(\.appDataManager) private var appDataManager
    @Published var cities: [CityRowViewModel] = []
    @Published var cityModel: [City] = []
    @Published var countries = Set<String>()
    
    init(cities: [City]) {
        self.cityModel = cities
        for city in cities {
            self.cities.append(CityRowViewModel(cityName: city.cityName,
                                                siteName: city.siteName,
                                                countryName: city.countryName,
                                                countryCode: city.countryCode))
            self.countries.insert(city.countryName)
        }
    }
    
    func addToFavourites(city: CityRowViewModel) {
        if let city = self.cityModel.first(where: { $0.cityName == city.cityName }) {
            if locationService.lastLocation?.cityName != city.cityName {
                UserSettings.addFavoriteCity(city)
            }
            self.appData.citySelectorClicked = false
            if UserSettings.selectedCity != city {
                UserSettings.selectedCity = city
            }
            appDataManager.fetchData(cityName: city.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
        }
    }
    
    func getCountries() -> [String] {
        return self.countries.sorted {
            $0 < $1
        }
    }
    
    func getCities() -> [CityRowViewModel] {
        return self.cities.sorted {
            $0.siteName < $1.siteName
        }
    }
}
