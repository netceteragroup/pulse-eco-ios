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
    
    @Published var selectedAppView: AppView = UserSettings().selectedAppView
    @Published var showSensorDetails: Bool = false
    @Published var selectedSensor: SensorPinModel?
    @Published var selectedSensorsForGraph: [SensorPinModel] = []
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
    @Published var selectedDate: Date = calendar.startOfDay(for: Date.now)
    @Published var calendarSelection: Date = calendar.startOfDay(for: Date.now)
    @Published var cityDataWrapper: CityDataWrapper = CityDataWrapper(sensorData: nil,
                                                                      currentValue: nil,
                                                                      measures: nil)
    @Published var weeklyDataWrapper: CityDataWrapper = CityDataWrapper(sensorData: nil,
                                                                        currentValue: nil,
                                                                        measures: nil)
    @Published var currentLocationIsSelected: Bool = false
    @Published var hourlySensors: [Int: [SensorPinModel]] = [:]
    @Published var cachedHourlySensorsByDay: [CacheDictionaryKey: [Int: [SensorPinModel]]] = [:]
    @Published var isTimelineSliderActive: Bool = false
    @Published var isWaitingToFetchFavouriteCitiesOveralls: Bool = true
    
    struct CacheDictionaryKey: Hashable {
        var date: Date
        var type: String
    }
    
    var cancellables = Set<AnyCancellable>()
    
    var cityIcon: Image {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        selectedCitySubscriber()
        cityValuesSubscriber()
    }
    
    private func selectedCitySubscriber() {
        $selectedCity
            .sink { [weak self] _ in
                guard let self else { return }
                cachedHourlySensorsByDay.removeAll()
                hourlySensors.removeAll()
            }
            .store(in: &cancelables)
    }
    
    private func cityValuesSubscriber() {
        userSettings.$cityValues
            .dropFirst()
            .sink { [weak self] values in
                guard let self else { return }
                for city in self.userSettings.favouriteCities {
                    if !values.contains(where: { city.cityName == $0.cityName }) {
                        self.isWaitingToFetchFavouriteCitiesOveralls = true
                        return
                    }
                }
                self.isWaitingToFetchFavouriteCitiesOveralls = false
                cancellables.removeAll()
            }
            .store(in: &cancellables)
    }
}
