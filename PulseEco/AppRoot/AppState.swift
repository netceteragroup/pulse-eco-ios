import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject, ViewModelDependency {
    var cancelables = Set<AnyCancellable>()
    
    @Published var selectedMeasureId: String = "pm10"
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
