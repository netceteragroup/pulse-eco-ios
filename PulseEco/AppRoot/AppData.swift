import Foundation
import SwiftUI
import Combine

class AppData: ObservableObject {
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
    
    @Published var measures: [Measure] = []
    @Published var citySensors: [Sensor] = []
    @Published var cityOverall: CityOverallValues?
    @Published var sensorsData24h: [SensorData] = []
    @Published var cities: [City] = []
    @Published var weeklyData: [DayDataWrapper] = []
    @Published var monthlyData: [DayDataWrapper] = []
    @Published var monthlyAverage: [DayDataWrapper] = []
    @Published var sensorDataForSelectedDate: [SensorData] = []
    @Published var dailySensorData: [SensorData] = []
    @Published var weeklyAverageForSensors: [SensorData] = []
        
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
