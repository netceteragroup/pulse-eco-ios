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
    @Published var monthlyAverage: CityDataWrapper = CityDataWrapper(sensorData: nil,
                                                                     currentValue: nil,
                                                                     measures: nil)
    
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
        self.appState.loadingMeasures = true
        Task { @MainActor in
            self.measures = await networkService.fetchMeasures() ?? []
            if let firstMeasureId = measures.first?.id {
                self.appState.selectedMeasureId = firstMeasureId
            }
            self.appState.loadingMeasures = false
        }
    }
    
    private struct CityValueWrapper {
        let cityOverall: CityOverallValues?
        let citySensors: [Sensor]
        let sensorsData: [SensorData]
        let sensorsData24h: [SensorData]
    }
    
    func getValuesForCity(cityName: String = UserSettings.selectedCity.cityName) {
        self.appState.loadingCityData = true
        Task { @MainActor in
            async let cityOverall = self.networkService.downloadCurrentData(for: cityName)
            async let citySensors = self.networkService.downloadSensorsAsync(cityName: cityName) ?? []
            async let sensorsData =
            self.networkService.currentDataSensor(cityName: cityName,
                                                  measureId: self.appState.selectedMeasureId) ?? []
            async let sensorsData24h = self.networkService.fetch24hDataForSensors(cityName: cityName) ?? []
            
            await self.fetchHistory(for: cityName, measureId: self.appState.selectedMeasureId)
            
            let wrapper = await CityValueWrapper(cityOverall: cityOverall,
                                                 citySensors: citySensors,
                                                 sensorsData: sensorsData,
                                                 sensorsData24h: sensorsData24h)
            self.cityOverall = wrapper.cityOverall
            self.citySensors = wrapper.citySensors
            self.sensorsData = wrapper.sensorsData
            self.sensorsData24h = wrapper.sensorsData24h
            self.appState.loadingCityData = false
            
            self.monthlyAverage =
            await networkService.fetchMonthAverages(cityName: cityName,
                                                          measureType: self.appState.selectedMeasureId,
                                                          selectedDate: self.appState.selectedDate)
        }
    }
    
    func emptyCityOverallValueList() {
        self.appState.userSettings.cityValues.removeAll()
    }
    
    func getCities() {
        Task {@MainActor in
            let cities = await networkService.fetchCities() ?? []
            self.cities = cities
            try await withThrowingTaskGroup(of: CityOverallValues.self) { group in
                for city in cities {
                    group.addTask {
                        let value = await NetworkService().downloadCurrentData(for: city.cityName)
                        return value ?? CityOverallValues(cityName: city.cityName, values: [:])
                    }
                }
                
                for try await overallValue in group {
                    self.appState.userSettings.cityValues.append(overallValue)
                }
            }
        }
    }
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        measures.filter { $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
    }
    
    func fetchDailyAverageDataForSensor(city: City,
                                        measure: Measure?,
                                        sensorId: String) {
        guard let measure = measure else { return }
        Task {
            self.sensorsDailyAverageData =
            await networkService.downloadDailyAverageDataForSensor(cityName: city.cityName,
                                                                   measureType: measure.id,
                                                                   sensorId: sensorId) ?? []
        }
    }
    
    @MainActor func fetchWeeklyAverages(cityName: String = UserSettings.selectedCity.cityName,
                                        measureId: String) {
        Task {
            appState.cityDataWrapper =
            await self.networkService.fetchAndWrapCityData(cityName: cityName,
                                                                     sensorType: measureId,
                                                                     selectedDate: appState.selectedDate)
            
            self.weeklyData =
            appState.cityDataWrapper
                .getDataFromRange(cityName: cityName,
                                  sensorType: measureId,
                                  from: calendar.date(byAdding: .day, value: -7, to: Date.now)!,
                                  to: calendar.date(byAdding: .day, value: +1, to: Date.now)!)
            await updatePins(selectedDate: appState.selectedDate)
            self.monthlyAverage =
            await networkService.fetchMonthAverages(cityName: cityName,
                                                          measureType: self.appState.selectedMeasureId,
                                                          selectedDate: self.appState.selectedDate)
        }
    }
    
    func getMonthlyValues(cityName: String = UserSettings.selectedCity.cityName,
                          measureId: String,
                          currentMonth: Int,
                          currentYear: Int) async {
        Task { @MainActor in
            appState.cityDataWrapper =
            await self.networkService.fetchAndWrapCityData(cityName: cityName,
                                                           sensorType: measureId,
                                                           selectedDate: appState.selectedDate)
            
            await fetchMonthlyData(selectedMonth: currentMonth, selectedYear: currentYear)
        }
    }
    
    @MainActor func fetchHistory(for cityName: String, measureId: String) async {
        fetchWeeklyAverages(cityName: cityName, measureId: measureId)
    
        await getMonthlyValues(cityName: cityName,
                               measureId: measureId,
                               currentMonth: appState.currentMonth,
                               currentYear: appState.currentYear)
    }
    
    func updatePins(selectedDate: Date) async {
        let from: Date = selectedDate
        let to: Date = calendar.date(bySettingHour: 23,
                                             minute: 59,
                                             second: 59,
                                             of: selectedDate)!
        
        Task { @MainActor in
            guard let dailySensorData =
                    await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
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

    func fetchMonthlyData (selectedMonth: Int, selectedYear: Int) async {

        Task { @MainActor in
            let newSensorData =
            await self.networkService.fetchDataForSelectedMonth(cityName: appState.selectedCity.cityName,
                                                                sensorType: appState.selectedMeasureId,
                                                                selectedMonth: selectedMonth,
                                                                selectedYear: selectedYear)

            self.appState.cityDataWrapper.updateSensorData(newSensorData)
                        
            self.monthlyData = appState.cityDataWrapper.getDataFromRange(cityName: appState.selectedCity.cityName,
                                                                         sensorType: appState.selectedMeasureId,
                                                                         from: Date.from(1, selectedMonth,
                                                                                         selectedYear)!,
                                                                         to: Date.now)
        }
    }
    func updateMonthlyColors (selectedYear: Int) async {
        let date = Date.from(1, 1, selectedYear)!
        self.monthlyAverage =
        await networkService.fetchMonthAverages(cityName: appState.selectedCity.cityName,
                                                      measureType: self.appState.selectedMeasureId,
                                                      selectedDate: date)
    }
}
