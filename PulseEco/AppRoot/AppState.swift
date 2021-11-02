import Foundation
import SwiftUI
class AppState: ObservableObject {
   
    @Published var selectedMeasure: String! = ""
    @Published var citySelectorClicked: Bool = false
    @Published var selectedCity: City = UserSettings.selectedCity {
        didSet {
            UserSettings.selectedCity = selectedCity
        }
    }
    @Published var showSensorDetails: Bool = false
    @Published var selectedSensor: SensorPinModel?
    @Published var blurBackground: Bool = false
    @Published var activeSheet: ActiveSheet?
    @Published var selectedLanguage: String = Trema.appLanguage
    @Published var newCitySelected: Bool = false
    
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
