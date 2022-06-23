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
    @Published var sensorPins: [SensorPinModel] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    @Published var userSettings: UserSettings = UserSettings()
    @Published var showingCalendar = false
    @Published var selectedDateAverageValue: String?
    @Published var currentMonth: Int = 0
    @Published var currentYear: Int = 0
    @Published var selectedDate: Date = calendar.startOfDay(for: Date.now)
    @Published var calendarSelection: Date = calendar.startOfDay(for: Date.now)
    @Published var cityDataWrapper: CityDataWrapper = CityDataWrapper(sensorData: nil,
                                                                      currentValue: nil,
                                                                      measures: nil)
    @Published var weeklyDataWrapper: CityDataWrapper = CityDataWrapper(sensorData: nil,
                                                                        currentValue: nil,
                                                                        measures: nil)
    
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
