
import Foundation

class CityRowVM: ObservableObject, Identifiable {
    var id: String { return cityName }
    var cityName: String
    var siteName: String
    var countryName: String
    var countryCode: String
    init(cityName: String, siteName: String, countryName: String, countryCode: String) {
        self.cityName = cityName
        self.countryCode = countryCode
        self.countryName = countryName
        self.siteName = siteName
    }
}
