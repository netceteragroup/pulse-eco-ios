import Foundation
import Combine

class AppDataSource: ObservableObject, ViewModelDependency {
    private let appState: AppState
    @Published var measures: [Measure] = [Measure.empty("PM10"),
                                          Measure.empty("PM25"),
                                          Measure.empty("Noise"),
                                          Measure.empty("Temperature"),
                                          Measure.empty("Humidity"),
                                          Measure.empty("Pressure"),
                                          Measure.empty("NO2"),
                                          Measure.empty("O3")]
    @Published var citySensors: [Sensor] = []
    @Published var cityOverall: CityOverallValues?
    @Published var userSettings: UserSettings = UserSettings()
    @Published var sensorsData: [SensorData] = []
    @Published var sensorsDailyAverageData: [SensorData] = []
    @Published var sensorsData24h: [SensorData] = []
    @Published var cities: [City] = []
    @Published var cancellationTokens: [AnyCancellable] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    @Published var currentMonth: Int = 0
    @Published var currentYear: Int = 0
    
    @MainActor var cityDataWrapper: CityDataWrapper = CityDataWrapper(sensorData: nil, currentValue: nil, measures: nil)
    @Published var weeklyData: [DayDataWrapper] = []
    @Published var monthlyData: [DayDataWrapper] = []
    
    var cancelables = Set<AnyCancellable>()
    var subscripiton: AnyCancellable?
    private let networkService = NetworkService()
    
    init(appState: AppState) {
        self.appState = appState
        
        getMeasures()
        getValuesForCity()
        
        subscripiton = RunLoop.main.schedule(after: RunLoop.main.now, interval: .seconds(600)) {
            self.emptyCityOverallValueList()
            self.getCities()
        } as? AnyCancellable
    }
    
    func getMeasures() {
        networkService.downloadMeasures().sink(receiveCompletion: { [weak self] _ in
            self?.loadingMeasures = false
        }, receiveValue: { [weak self] measures in
            self?.measures = measures
            if let firstMeasureId = measures.first?.id {
                self?.appState.selectedMeasureId = firstMeasureId
            }
            
        }).store(in: &cancelables)
    }
    
    func getValuesForCity(cityName: String = UserSettings.selectedCity.cityName) {
        getValues(cityName: cityName, measureId: self.appState.selectedMeasureId)
        getMonthlyValues(cityName: cityName,
                         measureId: self.appState.selectedMeasureId,
                         currentMonth: currentMonth,
                         currentYear: currentYear)
        
        self.loadingCityData = true
        Publishers.Zip4(networkService.downloadOverallValuesForCity(cityName: cityName),
                        networkService.downloadSensors(cityName: cityName),
                        networkService.downloadCurrentDataForSensors(cityName: cityName),
                        networkService.download24hDataForSensors(cityName: cityName))
        .sink { [weak self] _ in
            self?.loadingCityData = false
        } receiveValue: { [weak self] (cityOverallValues, sensors, sensorsData, sensorsData24) in
            self?.cityOverall = cityOverallValues
            self?.citySensors = sensors
            self?.sensorsData = sensorsData
            self?.sensorsData24h = sensorsData24
        }
        .store(in: &cancelables)
    }
    
    func emptyCityOverallValueList() {
        self.userSettings.cityValues.removeAll()
    }
    
    func getCities() {
        networkService.downloadCities().sink(receiveCompletion: { _ in
            self.cities.forEach { city in
                self.cancellationTokens.append(NetworkService().downloadOverallValuesForCity(cityName: city.cityName)
                    .sink(receiveCompletion: { _ in },
                          receiveValue: { values in
                    self.userSettings.cityValues.append(values)
                }))
            }
        }, receiveValue: { cities in
            self.cities = cities
        })
        .store(in: &cancelables)
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        measures.filter { $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
    }
    
    func getDailyAverageDataForSensor(city: City,
                                      measure: Measure?,
                                      sensorId: String) {
        guard let measure = measure else { return }
        networkService
            .downloadDailyAverageDataForSensor(cityName: city.cityName,
                                               measureType: measure.id,
                                               sensorId: sensorId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { dailyAverage in
                self.sensorsDailyAverageData = dailyAverage
            })
            .store(in: &cancelables)
    }
    
    func getValues(cityName: String = UserSettings.selectedCity.cityName,
                   measureId: String) {
        Task { @MainActor in
            cityDataWrapper = await self.networkService.downloadOverallCurrentMeasures(cityName: cityName,
                                                                                       sensorType: measureId)
            self.weeklyData = cityDataWrapper.getDataFromRange(cityName: cityName,
                                                               sensorType: measureId,
                                                               from: Calendar
                                                                .current
                                                                .date(byAdding: .day,
                                                                      value: -4,
                                                                      to: Date.now)!,
                                                               to: Calendar
                                                                .current
                                                                .date(byAdding: .day, value: +1, to: Date.now)!)
        }
    }
    
    func getMonthlyValues(cityName: String = UserSettings.selectedCity.cityName,
                          measureId: String,
                          currentMonth: Int,
                          currentYear: Int) {
        Task { @MainActor in
            cityDataWrapper = await self.networkService.downloadOverallCurrentMeasures(cityName: cityName,
                                                                                       sensorType: measureId)
            
            self.monthlyData = cityDataWrapper.getDataFromRange(cityName: cityName,
                                                                sensorType: measureId,
                                                                from: Date.from(1, currentMonth, currentYear)!,
                                                                to: Date.now)
        }
    }
}
