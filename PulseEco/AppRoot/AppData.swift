import Foundation
import SwiftUI
import Combine

class AppData: ObservableObject {
    @Published var selectedMeasureId: String = "pm10"
    @Published var selectedSensor: SensorPinModel?
    @Published var selectedSensorsForGraph: [SensorPinModel] = []
    @Published var sensorPins: [SensorPinModel] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    @Published var isWaitingToFetchFavoriteCitiesOveralls: Bool = true
    @Published var selectedDateAverageValue: String?
    @Published var selectedDate: Date = calendar.startOfDay(for: Date.now)
    @Published var selectedHour: Int = calendar.component(.hour, from: Date.now)
    @Published var sensorsData24h: [SensorData] = []
    @Published var weeklyData: [DayDataWrapper] = []
    @Published var monthlyData: [DayDataWrapper] = []
    @Published var monthlyAverage: [DayDataWrapper] = []
    @Published var dailySensorData: [SensorData] = []
    @Published var weeklyAverageForSensors: [SensorData] = []
    var cities: [City] = []
    var cityOverallValues: [CityOverallValues] = []
    var measures: [Measure] = []
    var citySensors: [Sensor] = []
    var cityOverall: CityOverallValues?
    var hourlySensors: [Int: [SensorPinModel]] = [:]
}
