import Foundation
import SwiftUI
class AppState: ObservableObject {
   
    @Published var selectedMeasure: String = "pm10"
    @Published var citySelectorClicked: Bool = false
    @Published var cityName: String = "Skopje"
    @Published var showSensorDetails: Bool = false
    @Published var selectedSensor: SensorPinModel?
    @Published var updateMapRegion: Bool = true
    @Published var updateMapAnnotations: Bool = true
    @Published var blurBackground: Bool = false
    @Published var showSheet: Bool = false
    @Published var activeSheet: ActiveSheet = .disclaimerView
    @Published var selectedLanguage: String = Trema.appLanguage
    @Published var getNewSensors: Bool = false
    
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
