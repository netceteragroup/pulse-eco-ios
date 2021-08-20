import Foundation
import SwiftUI
class AppVM: ObservableObject {
   
    @Published var selectedMeasure: String = "pm10"
    @Published var citySelectorClicked: Bool = false {
        didSet {
//            cityIcon = citySelectorClicked ? Image(uiImage: UIImage(named: "Triangle-up") ?? UIImage()) : Image(uiImage: UIImage(named: "Triangle") ?? UIImage())
             cityIcon = citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
        }
    }
    @Published var cityName: String = "Skopje"
    @Published var cityIcon: Image = Image(systemName: "chevron.down")
    @Published var showSensorDetails: Bool = false
    @Published var selectedSensor: SensorVM?
    @Published var updateMapRegion: Bool = true
    @Published var updateMapAnnotations: Bool = true
    @Published var blurBackground: Bool = false
    @Published var showSheet: Bool = false
    @Published var activeSheet: ActiveSheet = .disclaimerView
    @Published var appLanguage: String = Trema.appLanguage
}
