import Foundation
import Factory

@MainActor
class CityListViewModel: ObservableObject {
    private let cities: [CityRowViewModel]
    private let cityModel: [City]
    let countries: [String]
    
    @Injected(\.locationService) private var locationService
    @Injected(\.appDataManager) private var appDataManager
    @Injected(\.refreshService) private var refreshService
    
    init(cities: [City]) {
        self.cityModel = cities
        self.cities = cities.map { CityRowViewModel(cityName: $0.cityName,
                                                    siteName: $0.siteName,
                                                    countryName: $0.countryName,
                                                    countryCode: $0.countryCode) }.sorted { $0.siteName < $1.siteName }
        countries = Set(cities.map { $0.countryName }).sorted { $0 < $1 }
    }
    
    func citiesFromCountry(_ country: String) -> [CityRowViewModel] {
        cities.filter { $0.countryName == country }
    }
    
    func addToFavorites(city: CityRowViewModel) {
        if let city = self.cityModel.first(where: { $0.cityName == city.cityName }) {
            if locationService.lastLocation?.cityName != city.cityName {
                UserSettings.addFavoriteCity(city)
            }
            if UserSettings.selectedCity != city {
                UserSettings.selectedCity = city
            }
            refreshService.updateRefreshDate()
            appDataManager.fetchData()
        }
    }
    
    func getFilteredCities(searchText: String) -> [CityRowViewModel] {
        cities.filter {
            $0.cityName.lowercased().contains(searchText.lowercased()) ||
            $0.countryName.lowercased().contains(searchText.lowercased())
        }
    }
    
    func shouldAddCheckmark(city: CityRowViewModel) -> Bool {
        UserSettings.favoriteCities.contains(where: { $0.cityName == city.cityName })
    }
}
