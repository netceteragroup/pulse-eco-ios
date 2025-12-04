import Foundation
import Combine
import UIKit

@MainActor
class AppDataSource: ObservableObject {
    private let logger = SystemLoggerAdapter(category: "AppDataSource")

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
    @Published var hourlyData: [Int: [SensorData]] = [:]
    @Published var sensorDataForSelectedDate: [SensorData] = []
    
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
        logger.logDebug("Fetching values for city: \(cityName)")
        self.appState.loadingCityData = true
        Task {
            async let cityOverall = self.networkService.downloadCurrentData(for: cityName)
            async let citySensors = self.networkService.downloadSensorsAsync(cityName: cityName) ?? []
            async let sensorsData = self.networkService.currentDataSensor(cityName: cityName,
                                                                          measureId: self.appState.selectedMeasureId) ?? []
            async let sensorsData24h = self.networkService.fetch24hDataForSensors(cityName: cityName) ?? []
            
            if Date().isSameDay(with: appState.selectedDate) {
                if let averageValueForSensorType = await cityOverall?.values[appState.selectedMeasureId] {
                    self.appState.selectedDateAverageValue = averageValueForSensorType
                }
            }

            let wrapper = await CityValueWrapper(cityOverall: cityOverall,
                                                 citySensors: citySensors,
                                                 sensorsData: sensorsData,
                                                 sensorsData24h: sensorsData24h)
            self.cityOverall = wrapper.cityOverall
            self.citySensors = wrapper.citySensors
            self.sensorsData = wrapper.sensorsData
            self.sensorsData24h = wrapper.sensorsData24h
            logger.logDebug("City data fetched: cityOverall = \(wrapper.cityOverall?.cityName ?? "nil"), sensors = \(wrapper.citySensors.count)")

            await updatePins(selectedDate: appState.selectedDate)
            await fetchHistory(for: cityName, measureId: appState.selectedMeasureId)
            self.appState.loadingCityData = false
        }
    }
    
    func emptyCityOverallValueList() {
        UserSettings.cityValues.removeAll()
    }
    
    func getCities() {
        Task {
            let cities = await networkService.fetchCities() ?? []
            self.cities = cities
            let overallCities = await networkService.downloadCurrentData(cityNames: cities.map { $0.cityName.lowercased() })
            UserSettings.cityValues.append(contentsOf: overallCities)
            appState.isWaitingToFetchFavouriteCitiesOveralls = false
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
    
    private func fetchCachedValues(dailySensorData: [SensorData], groupById: [String: [SensorData]]) {
        if appState.cachedHourlySensorsByDay[AppState.CacheDictionaryKey(date: appState.selectedDate, type: appState.selectedMeasureId)] == nil {
            appState.cachedHourlySensorsByDay[AppState.CacheDictionaryKey(date: appState.selectedDate, type: appState.selectedMeasureId)] = groupByHour(sensorData: dailySensorData, groupById: groupById)
        }
        appState.hourlySensors = appState.cachedHourlySensorsByDay[AppState.CacheDictionaryKey(date: appState.selectedDate, type: appState.selectedMeasureId)]!
        self.appState.sensorPins = appState.hourlySensors[calendar.component(.hour, from: .now)] ?? []
    }
    
    private func fetchForCurrentValues(groupById: [String: [SensorData]]) {
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
    
    func updatePins(selectedDate: Date) async {
        let from: Date = selectedDate
        let to: Date = calendar.date(bySettingHour: 23,
                                     minute: 59,
                                     second: 59,
                                     of: selectedDate)!
        guard let dailySensorData =
                await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                     measureId: self.appState.selectedMeasureId,
                                                     from: from,
                                                     to: to)
        else { return }
        let groupById = Dictionary(grouping: dailySensorData, by: \.sensorID)
        
        if appState.selectedDate == Date.now {
            fetchForCurrentValues(groupById: groupById)
        }
        else {
            fetchCachedValues(dailySensorData: dailySensorData, groupById: groupById)
        }
        await setAverageValueForSelectedDate(cityName: appState.selectedCity.cityName, sensorType: appState.selectedMeasureId, selectedDate: appState.selectedDate)
    }
    
    private func groupByHour(sensorData: [SensorData],
                             groupById: [String: [SensorData]]) -> [Int: [SensorPinModel]] {
        
        struct SensorIdHour: Hashable {
            let hour: Int
            let sensorId: String
        }
        
        var result: [Int: [SensorData]] = [:]
        var seen: Set<SensorIdHour> = []
        let calendar = Calendar.current
        
        for data in sensorData {
            guard let date = DateFormatter.iso8601Full.date(from: data.stamp) else { continue }
            
            let hour = calendar.component(.hour, from: date)
            
            if !seen.contains(SensorIdHour(hour: hour, sensorId: data.sensorID)) {
                seen.insert(SensorIdHour(hour: hour, sensorId: data.sensorID))
                
                if result[hour] == nil {
                    result[hour] = []
                }
                result[hour]?.append(data)
            }
        }
        
        addFor12Pm(result: &result, sensorData: sensorData)
        
        var sensorPinModelsByHour: [Int: [SensorPinModel]] = [:]
        
        for pair in result {
            sensorPinModelsByHour[pair.key] = combine(sensors: citySensors, sensorsData: result[pair.key]!, selectedMeasure: getCurrentMeasure(selectedMeasure: appState.selectedMeasureId))
        }
        
        return sensorPinModelsByHour
    }
    
    private func addFor12Pm(result: inout [Int: [SensorData]], sensorData: [SensorData]) {
        var seen: Set<String> = []
        
        for sensor in sensorData.reversed() {
            guard let date = DateFormatter.iso8601Full.date(from: sensor.stamp) else { continue }
            let hourAndMinutes = calendar.dateComponents([.hour, .minute], from: date)
            if hourAndMinutes.hour ?? 0 < 23 || hourAndMinutes.minute ?? 0 < 30 {
               break
            }
            if !seen.contains(sensor.sensorID) {
                seen.insert(sensor.sensorID)
                if result[24] == nil {
                    result[24] = []
                }
                result[24]?.append(sensor)
            }
        }
    }
    
    private func getHourDate(_ hour: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: appState.selectedDate)
        components.hour = hour
        return calendar.date(from: components)!
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
        self.appState.selectedDate = self.appState.calendarSelection
        if appState.selectedDate.isSameDay(with: appState.calendarSelection) {
            await fetchWeeklyAverages(measureId: self.appState.selectedMeasureId,
                                      selectedDate: self.appState.calendarSelection)
        }
        await updatePins(selectedDate: appState.calendarSelection)
        await getSensorDataForSelectedDate(cityName: self.appState.selectedCity.cityName, sensorType: self.appState.selectedMeasureId, selectedDate: self.appState.calendarSelection)
    }
    
    func updateWeeklyDataWrapper(cityName: String, measureId: String, selectedDate: Date) async {
        appState.weeklyDataWrapper =
        await self.networkService.fetchAndWrapCityData(cityName: cityName,
                                                       sensorType: measureId,
                                                       selectedDate: appState.calendarSelection)
    }
    
    func setAverageValueForSelectedDate(cityName: String, sensorType: String, selectedDate: Date) async {
        self.appState.selectedDateAverageValue =
        self.appState.weeklyDataWrapper.getDataFromRange(cityName: cityName,
                                                         sensorType: sensorType,
                                                         from: selectedDate,
                                                         to: calendar.date(byAdding: .day,
                                                                           value: +1,
                                                                           to: selectedDate)!).first?.value
    }
    
    func getSensorDataForSelectedDate(cityName: String, sensorType: String, selectedDate: Date) async {
        self.sensorDataForSelectedDate = await networkService.fetchSensorData(cityName: cityName, measureId: sensorType, from: selectedDate, to: calendar.date(byAdding: .day, value: +1, to: selectedDate)!) ?? []
    }
}
