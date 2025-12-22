import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var selectedMeasureId: String = "pm10"
    @Published var citySelectorClicked: Bool = false
    @Published var showSensorDetails: Bool = true
    @Published var selectedSensor: SensorPinModel?
    @Published var selectedSensorsForGraph: [SensorPinModel] = []
    @Published var blurBackground: Bool = false
    @Published var sensorPins: [SensorPinModel] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    @Published var showingCalendar = false
    @Published var selectedDateAverageValue: String?
    @Published var selectedDate: Date = calendar.startOfDay(for: Date.now)
    @Published var hourlySensors: [Int: [SensorPinModel]] = [:]
    @Published var isTimelineSliderActive: Bool = false
    @Published var isWaitingToFetchFavouriteCitiesOveralls: Bool = true
        
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
