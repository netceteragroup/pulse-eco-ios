import Foundation
import SwiftUI
import Combine

protocol AppDataProtocol: ObservableObject {
    var selectedMeasureId: String { get set }
    var citySelectorClicked: Bool { get set }
    var showSensorDetails: Bool { get set }
    var selectedSensor: SensorPinModel?  { get set }
    var selectedSensorsForGraph: [SensorPinModel]  { get set }
    var blurBackground: Bool  { get set }
    var sensorPins: [SensorPinModel] { get set }
    var loadingCityData: Bool { get set }
    var loadingMeasures: Bool { get set }
    var showingCalendar: Bool { get set }
    var selectedDateAverageValue: String? { get set }
    var selectedDate: Date { get set }
    var hourlySensors: [Int: [SensorPinModel]] { get set }
    var isTimelineSliderActive: Bool { get set }
    var isWaitingToFetchFavouriteCitiesOveralls: Bool { get set }
    var measures: [Measure] { get set }
    var citySensors: [Sensor] { get set }
    var cityOverall: CityOverallValues? { get set }
    var sensorsData24h: [SensorData] { get set }
    var cities: [City] { get set }
    var weeklyData: [DayDataWrapper] { get set }
    var monthlyData: [DayDataWrapper] { get set }
    var monthlyAverage: [DayDataWrapper] { get set }
    var sensorDataForSelectedDate: [SensorData] { get set }
    var dailySensorData: [SensorData] { get set }
    var weeklyAverageForSensors: [SensorData] { get set }
    
    var loadingMeasuresPublisher: AnyPublisher<Bool, Never> { get }
    var showingCalendarPublisher: AnyPublisher<Bool, Never> { get }
    var selectedDatePublisher: AnyPublisher<Date, Never> { get }
    
    var cityIcon: Image { get }
}

class AppData: AppDataProtocol {
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
    
    var loadingMeasuresPublisher: AnyPublisher<Bool, Never> {
        $loadingMeasures.eraseToAnyPublisher()
    }
    
    var showingCalendarPublisher: AnyPublisher<Bool, Never> {
        $showingCalendar.eraseToAnyPublisher()
    }
    
    var selectedDatePublisher: AnyPublisher<Date, Never> {
        $selectedDate.eraseToAnyPublisher()
    }
        
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}
