import Foundation
import Combine
import UIKit

@MainActor
class AppDataSource: ObservableObject, ViewModelDependency {
    let appState: AppState
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
        Task {
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
        Task {
            async let cityOverall = self.networkService.downloadCurrentData(for: cityName)
            async let citySensors = self.networkService.downloadSensorsAsync(cityName: cityName) ?? []
            async let sensorsData =
            self.networkService.currentDataSensor(cityName: cityName,
                                                  measureId: self.appState.selectedMeasureId) ?? []
            async let sensorsData24h = self.networkService.fetch24hDataForSensors(cityName: cityName) ?? []
            
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
        Task {
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
    
    func fetchWeeklyAverages(cityName: String = UserSettings.selectedCity.cityName,
                                        measureId: String,
                                        selectedDate: Date) async {
        Task {
            await updateWeeklyDataWrapper(cityName: cityName, measureId: measureId, selectedDate: appState.calendarSelection)
            
            let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: selectedDate)!
            let threeDaysLater = calendar.date(byAdding: .day, value: +4, to: selectedDate)!
            if threeDaysLater < calendar.startOfDay(for: Date.now) {
                self.weeklyData =
                appState.weeklyDataWrapper
                    .getDataFromRange(cityName: cityName,
                                      sensorType: measureId,
                                      from: threeDaysAgo,
                                      to: threeDaysLater)
                
                guard let today = fetchTodayValue(cityName: cityName, sensorType: measureId) else {
                    return
                }
                self.weeklyData.append(today)
                
            } else {
                self.weeklyData =
                appState.weeklyDataWrapper
                    .getDataFromRange(cityName: cityName,
                                      sensorType: measureId,
                                      from: calendar.date(byAdding: .day, value: -7, to: Date.now)!,
                                      to: calendar.date(byAdding: .day, value: +1, to: Date.now)!)
            }
            
            await updatePins(selectedDate: appState.selectedDate)
        }
    }
    
    func fetchTodayValue(cityName: String, sensorType: String) -> DayDataWrapper? {
        return appState.weeklyDataWrapper.getDataFromRange(cityName: cityName,
                                                           sensorType: sensorType,
                                                           from: calendar.startOfDay(for: Date.now),
                                                           to: calendar.date(byAdding: .day,
                                                                             value: +1,
                                                                             to: Date.now)!).first
    }
    
    func getMonthlyValues(cityName: String = UserSettings.selectedCity.cityName,
                          measureId: String,
                          currentMonth: Int,
                          currentYear: Int) async {
        Task {
            appState.cityDataWrapper =
            await self.networkService.fetchAndWrapCityData(cityName: cityName,
                                                           sensorType: measureId,
                                                           selectedDate: appState.selectedDate)
            
            await fetchMonthlyDayData(selectedMonth: currentMonth, selectedYear: currentYear)
        }
    }
    
    func fetchHistory(for cityName: String, measureId: String) async {
        await fetchWeeklyAverages(cityName: cityName,
                                  measureId: measureId,
                                  selectedDate: appState.calendarSelection)
        
        await getMonthlyValues(cityName: cityName,
                               measureId: measureId,
                               currentMonth: calendar.component(.month, from: appState.selectedDate),
                               currentYear: calendar.component(.year, from: appState.selectedDate))
    }
    
    func updatePins(selectedDate: Date) async {
        let from: Date = selectedDate
        let to: Date = calendar.date(bySettingHour: 23,
                                     minute: 59,
                                     second: 59,
                                     of: selectedDate)!
        
        Task {
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
        await setAverageValueforSelectedDate(cityName: appState.selectedCity.cityName, sensorType: appState.selectedMeasureId, selectedDate: appState.selectedDate)
    }
    
    func fetchMonthlyDayData (selectedMonth: Int, selectedYear: Int) async {
        Task {
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
    
    func selectFromCalendar () async {
        
        if appState.selectedDate.isSameDay(with: appState.calendarSelection) {
            await fetchWeeklyAverages(measureId: self.appState.selectedMeasureId,
                                      selectedDate: self.appState.selectedDate)
        }
    }
    
    func updateWeeklyDataWrapper(cityName: String, measureId: String, selectedDate: Date) async {
        appState.weeklyDataWrapper =
        await self.networkService.fetchAndWrapCityData(cityName: cityName,
                                                       sensorType: measureId,
                                                       selectedDate: appState.calendarSelection)
    }
    
    func setAverageValueforSelectedDate(cityName: String, sensorType: String, selectedDate: Date) async {
        if Date().isSameDay(with: selectedDate) {
            let averageValues = await self.networkService.downloadCurrentData(for: cityName)
            if let averageValueForSensorType = averageValues?.values[sensorType] {
                self.appState.selectedDateAverageValue = averageValueForSensorType
                return
            }
        }
        self.appState.selectedDateAverageValue =
        self.appState.weeklyDataWrapper.getDataFromRange(cityName: cityName,
                                                         sensorType: sensorType,
                                                         from: selectedDate,
                                                         to: calendar.date(byAdding: .day,
                                                                           value: +1,
                                                                           to: selectedDate)!).first?.value
    }
}
