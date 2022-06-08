import Foundation
import Combine
import UIKit

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
    @Published var sensorsData: [SensorData] = []
    @Published var sensorsDailyAverageData: [SensorData] = []
    @Published var sensorsData24h: [SensorData] = []
    @Published var cities: [City] = []
    @Published var cancellationTokens: [AnyCancellable] = []
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
            self?.appState.loadingMeasures = false
        }, receiveValue: { [weak self] measures in
            self?.measures = measures
            if let firstMeasureId = measures.first?.id {
                self?.appState.selectedMeasureId = firstMeasureId
            }
        }).store(in: &cancelables)
    }
    
    func getValuesForCity(cityName: String = UserSettings.selectedCity.cityName) {
        Task {
            await fetchHistory(for: cityName, measureId: self.appState.selectedMeasureId)
//            await fetchMonthlyData()
        }
        self.appState.loadingCityData = true
        Publishers.Zip4(networkService.downloadOverallValuesForCity(cityName: cityName),
                        networkService.downloadSensors(cityName: cityName),
                        networkService.downloadCurrentDataForSensors(cityName: cityName),
                        networkService.download24hDataForSensors(cityName: cityName))
        .sink { [weak self] _ in
            self?.appState.loadingCityData = false
        } receiveValue: { [weak self] (cityOverallValues, sensors, sensorsData, sensorsData24) in
            self?.cityOverall = cityOverallValues
            self?.citySensors = sensors
            self?.sensorsData = sensorsData
            self?.sensorsData24h = sensorsData24
        }
        .store(in: &cancelables)
    }
    
    func emptyCityOverallValueList() {
        self.appState.userSettings.cityValues.removeAll()
    }
    
    func getCities() {
        networkService.downloadCities().sink(receiveCompletion: { _ in
            self.cities.forEach { city in
                self.cancellationTokens.append(NetworkService().downloadOverallValuesForCity(cityName: city.cityName)
                    .sink(receiveCompletion: { _ in },
                          receiveValue: { values in
                    self.appState.userSettings.cityValues.append(values)
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
    
    func fetchDailyAverageDataForSensor(city: City,
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
    
    @MainActor func fetchWeeklyAverages(cityName: String = UserSettings.selectedCity.cityName,
                                        measureId: String) {
        Task {
            appState.cityDataWrapper =
            await self.networkService.downloadOverallCurrentMeasures(cityName: cityName, sensorType: measureId)
            
            self.weeklyData =
            appState.cityDataWrapper.getDataFromRange(cityName: cityName,
                                                      sensorType: measureId,
                                                      from: Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!,
                                                      to: Calendar.current.date(byAdding: .day, value: +1, to: Date.now)!)
            
            let today: [DayDataWrapper] =
            appState.cityDataWrapper.getDataFromRange(cityName: cityName,
                                                      sensorType: measureId,
                                                      from: Calendar.current.startOfDay(for: Date.now),
                                                      to: Calendar.current.date(byAdding: .day,
                                                                                value: +1,
                                                                                to: Calendar.current
                                                                                    .startOfDay(for: Date.now))!)
            
            self.weeklyData.append(contentsOf: today)
        }
    }
    
    func getMonthlyValues(cityName: String = UserSettings.selectedCity.cityName,
                          measureId: String,
                          currentMonth: Int,
                          currentYear: Int) {
        Task { @MainActor in
            appState.cityDataWrapper =
            await self.networkService.downloadOverallCurrentMeasures(cityName: cityName, sensorType: measureId)
            
            self.monthlyData = appState.cityDataWrapper.getDataFromRange(cityName: cityName,
                                                                         sensorType: measureId,
                                                                         from: Date.from(1, currentMonth, currentYear)!,
                                                                         to: Date.now)
        }
    }
    
    @MainActor func fetchHistory(for cityName: String, measureId: String) {
        fetchWeeklyAverages(cityName: cityName, measureId: measureId)
        getMonthlyValues(cityName: cityName,
                         measureId: measureId,
                         currentMonth: appState.currentMonth,
                         currentYear: appState.currentYear)
    }
    
    func updatePins(selectedDate: Date) async {
        let from: Date = selectedDate
        let to: Date = Calendar.current.date(bySettingHour: 23,
                                             minute: 59,
                                             second: 59,
                                             of: selectedDate)!
        
        Task { @MainActor in
            guard let dailySensorData =
                    await networkService.downloadSensorData(cityName: UserSettings.selectedCity.cityName,
                                                            measureId: self.appState.selectedMeasureId,
                                                            from: from,
                                                            to: to)
            else { return }
            
            let groupById = Dictionary(grouping: dailySensorData, by: \.sensorID)
            var processedSensorData: [SensorData] = []
            
            for (key, value) in groupById {
                let average = String(value.averageValue())
                if let sensor = value.first {
                    processedSensorData.append(SensorData(sensorID: key,
                                                          stamp: sensor.stamp,
                                                          type: sensor.type,
                                                          position: sensor.position,
                                                          value: average))
                }
            }
            let result: [SensorPinModel] = combine(sensors: citySensors,
                                                   sensorsData: processedSensorData,
                                                   selectedMeasure:
                                                    getCurrentMeasure(selectedMeasure: self.appState.selectedMeasureId))
            
            self.appState.sensorPins = result
        }
    }
//
//    func fetchMonthlyData () async -> [SensorData] {
//
//        let selectedMonth = Calendar.current.dateComponents([.month], from: appState.selectedDate).month!
//        let selectedYear = Calendar.current.dateComponents([.year], from: appState.selectedDate).year!
//
//        let result: [SensorData] =
//        await self.networkService.fetchDataForSelectedMonth(cityName: appState.selectedCity.cityName,
//                                                            sensorType: appState.selectedMeasureId,
//                                                            selectedMonth: selectedMonth,
//                                                            selectedYear: selectedYear)
//
//        return result
//
//    }
}
