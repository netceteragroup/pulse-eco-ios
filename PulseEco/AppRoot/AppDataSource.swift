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
        self.appState.loadingMeasures = true
        Task { @MainActor in
            self.measures = await networkService.fetchMeasures() ?? []
            if let firstMeasureId = measures.first?.id {
                self.appState.selectedMeasureId = firstMeasureId
            }
            self.appState.loadingMeasures = false
        }
    }
    
    func getValuesForCity(cityName: String = UserSettings.selectedCity.cityName) {
        self.appState.loadingCityData = true
        Task { @MainActor in
            await fetchHistory(for: cityName, measureId: self.appState.selectedMeasureId)
            self.cityOverall = await networkService.downloadCurrentData(for: cityName)
            self.citySensors = await networkService.downloadSensorsAsync(cityName: cityName) ?? []
            self.sensorsData =
                await networkService.currentDataSensor(cityName: cityName,
                                                       measureId: self.appState.selectedMeasureId) ?? []
            self.sensorsData24h = await networkService.fetch24hDataForSensors(cityName: cityName) ?? []
            self.appState.loadingCityData = false
        }
    }
    
    func emptyCityOverallValueList() {
        self.appState.userSettings.cityValues.removeAll()
    }
    
    func getCities() {
        
        Task { @MainActor in
            
            async let cities = await networkService.fetchCities() ?? []
            self.cities = await cities
            for city in await cities {
                let value = await NetworkService().downloadCurrentData(for: city.cityName)
                self.appState.userSettings.cityValues.append(value ??
                                                             CityOverallValues(cityName: city.cityName,
                                                                               values: [:]))
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

        let newMonth = (selectedMonth != 0) ?
        selectedMonth : calendar.dateComponents([.month], from: Date.now).month!
        let newYear = (selectedYear != 0) ?
        selectedYear : calendar.dateComponents([.year], from: Date.now).year!
        
        Task { @MainActor in
            self.appState.cityDataWrapper.sensorData =
            await self.networkService.fetchDataForSelectedMonth(cityName: appState.selectedCity.cityName,
                                                                sensorType: appState.selectedMeasureId,
                                                                selectedMonth: newMonth,
                                                                selectedYear: newYear)
            
            self.monthlyData = appState.cityDataWrapper.getDataFromRange(cityName: appState.selectedCity.cityName,
                                                                         sensorType: appState.selectedMeasureId,
                                                                         from: Date.from(1, newMonth, newYear)!,
                                                                         to: Date.now)
        }
    }
}
