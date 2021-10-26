
import Foundation

class CityRowViewModel: ObservableObject, Identifiable, Equatable {
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
    
    static func == (lhs: CityRowViewModel, rhs: CityRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
