import Foundation
import SwiftUI

class FavouriteCityRowViewModel: ObservableObject, Identifiable, Equatable {
    static func == (lhs: FavouriteCityRowViewModel, rhs: FavouriteCityRowViewModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.value == rhs.value &&
        lhs.color == rhs.color &&
        lhs.unit == rhs.unit &&
        lhs.noReadings == rhs.noReadings &&
        lhs.message == rhs.message
    }
    
    var id: String { return cityName }
    var cityName: String
    var siteName: String
    var countryCode: String
    var countryName: String
    var message: String
    var value: Float
    var color: Color
    var unit: String
    var noReadings: Bool
    var noReadingsImage: UIImage = UIImage(named: "exclamation") ?? UIImage()

    init(city: City = City(),
         message: String = Trema.text(for: "no_data_available"),
         value: String? = "3",
         unit: String = "µq/m3",
         color: Color = Color.gray) {
        self.cityName = city.cityName
        self.siteName = city.siteName
        self.countryCode = city.countryCode
        self.countryName = city.countryName
        self.message = message
        if let val = value {
            if let floatValue = Float(val) {
                self.value = floatValue
                self.noReadings = false
                self.color = color
            } else {
                self.noReadings = true
                self.value = 0
                self.color = Color(AppColors.gray)
            }
        } else {
            self.noReadings = true
            self.value = 0
            self.color = Color(AppColors.gray)
        }
        self.unit = unit
    }
}
