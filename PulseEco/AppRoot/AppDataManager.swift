import Foundation
import Combine
import UIKit
import Factory

@MainActor
protocol AppDataManagerProtocol {
    func getMeasures()
    func startInitialFetch()
    func fetchData()
    func selectFromCalendar(selectedDate: Date)
    func selectFromDateSlider(selectedDate: Date)
    func selectFromHourlySlider(selectedHour: Int)
    func selectFromSensorType(selectedMeasureId: String)
    func getCurrentMeasure(selectedMeasure: String) -> Measure
    func fetchMonthlyDayData(selectedMonth: Int, selectedYear: Int) async
    func updatePins(selectedDate: Date) async
    func updateWeeklyAverageForSensors(selectedDate: Date) async
    func updateMonthlyColors(selectedYear: Int) async
    var appData: AppData { get }
    var onSensorPinsUpdated: PassthroughSubject<[SensorPinModel], Never> { get }
}

class AppDataManager: AppDataManagerProtocol {
    @Injected(\.networkService) private var networkService
    private let logger = SystemLoggerAdapter(category: "AppDataManager")

    let appData: AppData
    
    let onSensorPinsUpdated = PassthroughSubject<[SensorPinModel], Never>()
        
    private var measuresTask = Task {}
        
    init(appData: AppData) {
        self.appData = appData
    }
    
    @MainActor
    func getMeasures() {
        self.appData.loadingMeasures = true
        measuresTask = Task {
            let measures = await networkService.fetchMeasures() ?? []
            appData.measures = measures
            if let firstMeasureId = measures.first?.id {
                self.appData.selectedMeasureId = firstMeasureId
            }
            self.appData.loadingMeasures = false
        }
    }
    
    func startInitialFetch() {
        scheduleFetchCitiesOnRepeat()
        fetchData()
        getMeasures()
    }
        
    func fetchData() {
        let cityName = UserSettings.selectedCity.cityName
        let sensorType = appData.selectedMeasureId
        let selectedDate = appData.selectedDate
        logger.logDebug("Fetching values for city: \(cityName)")
        guard let selectedMonth = selectedDate.getMonth,
              let selectedYear = selectedDate.getYear else { return }
        Task {
            self.appData.loadingCityData = true
            async let cityOverall = networkService.downloadCurrentData(for: cityName)
            async let citySensors = networkService.downloadSensorsAsync(cityName: cityName) ?? []
            async let dailySensorData = fetchDataForSelectedMonth(cityName: cityName,
                                                                  sensorType: sensorType,
                                                                  selectedMonth: selectedMonth,
                                                                  selectedYear: selectedYear)
            
            await mapCityData(cityOverall: cityOverall,
                              citySensors: citySensors,
                              overallSensorData: dailySensorData)
            await measuresTask.value
            mapMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
            mapWeeklyAverages()
            
            await updatePins(selectedDate: appData.selectedDate)
            self.appData.loadingCityData = false
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appData.selectedDate)
        }
    }
    
    func selectFromCalendar(selectedDate: Date) {
        appData.selectedDate = selectedDate
        if selectedDate.isSameDay(with: Date.now) {
            appData.selectedHour = calendar.component(.hour, from: Date.now)
        }
        Task {
            mapWeeklyAverages()
            await updatePins(selectedDate: appData.selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appData.selectedDate)
        }
    }
    
    func selectFromDateSlider(selectedDate: Date) {
        if selectedDate.isSameDay(with: Date.now) && !appData.selectedDate.isSameMonth(with: selectedDate) {
            Task {
                await fetchMonthlyDayData(selectedMonth: selectedDate.getMonth ?? 0, selectedYear: selectedDate.getYear ?? 0)
            }
        }
        appData.selectedDate = selectedDate
        if selectedDate.isSameDay(with: Date.now) {
            appData.selectedHour = calendar.component(.hour, from: Date.now)
        }
        Task {
            await updatePins(selectedDate: selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: selectedDate)
        }
    }
    
    func selectFromSensorType(selectedMeasureId: String) {
        appData.selectedMeasureId = selectedMeasureId
        let components = Calendar.current.dateComponents([.month, .year], from: appData.selectedDate)
        guard let selectedMonth = components.month,
              let selectedYear = components.year else { return }
        Task {
            await fetchMonthlyDayData(selectedMonth: selectedMonth, selectedYear: selectedYear)
            mapWeeklyAverages()
            await updatePins(selectedDate: appData.selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appData.selectedDate)
        }
    }
    
    func selectFromHourlySlider(selectedHour: Int) {
        appData.selectedHour = selectedHour
        mapPins()
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        appData.measures.first { $0.id.lowercased() == selectedMeasure.lowercased() } ?? Measure.empty()
    }
    
    func fetchMonthlyDayData(selectedMonth: Int, selectedYear: Int) async {
        appData.dailySensorData = await fetchDataForSelectedMonth(cityName: UserSettings.selectedCity.cityName,
                                                          sensorType: appData.selectedMeasureId,
                                                          selectedMonth: selectedMonth,
                                                          selectedYear: selectedYear)
        mapMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
    }
    
    func updatePins(selectedDate: Date) async {
        guard let to: Date = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) else { return }
        let sensorsData24h =  await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                               measureId: self.appData.selectedMeasureId,
                                                               from: selectedDate,
                                                               to: to) ?? []
        appData.sensorsData24h = sensorsData24h
        let selectedMeasure = getCurrentMeasure(selectedMeasure: appData.selectedMeasureId)
        appData.hourlySensors = SensorMapper.groupByHour(sensorData: sensorsData24h, sensors: appData.citySensors, selectedMeasure: selectedMeasure)
        mapPins()
    }
    
    func updateWeeklyAverageForSensors(selectedDate: Date) async {
        guard let from = calendar.date(byAdding: .day, value: -7, to: selectedDate) else { return }
        let weeklyAverageForSensors = await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                                       measureId: self.appData.selectedMeasureId,
                                                                       from: from,
                                                                       to: selectedDate) ?? []
        appData.weeklyAverageForSensors = weeklyAverageForSensors
    }
    
    func updateMonthlyColors(selectedYear: Int) async {
        guard let from = Date.from(1, 1, selectedYear),
              let to = Date.from(31, 12, selectedYear) else { return }
        let sensorData = await networkService.fetchMonthlyAverage(cityName: UserSettings.selectedCity.cityName,
                                                                  measureType: self.appData.selectedMeasureId,
                                                                  selectedDate: from)
        let monthlyAverage = DataFromRangeMapper.getDataFromRange(sensorType: self.appData.selectedMeasureId,
                                                              sensorData: sensorData ?? [],
                                                                  measures: appData.measures,
                                                                  cityOverall: appData.cityOverall,
                                                              from: from,
                                                              to: to)
        appData.monthlyAverage = monthlyAverage
    }
    
    private func scheduleFetchCitiesOnRepeat() {
        Task {
            while !Task.isCancelled {
                appData.cityOverallValues.removeAll()
                await getCities()
                try? await Task.sleep(nanoseconds: 600 * 1_000_000_000)
            }
        }
    }
    
    private func mapPins() {
        appData.sensorPins = appData.hourlySensors[appData.selectedHour] ?? []
        appData.selectedDateAverageValue = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                                 sensorData: appData.dailySensorData,
                                                                                 measures: appData.measures,
                                                                                 cityOverall: appData.cityOverall,
                                                                                 from: appData.selectedDate,
                                                                                 to: calendar.date(byAdding: .day, value: +1, to: appData.selectedDate)!).first?.value ?? ""
        onSensorPinsUpdated.send(self.appData.sensorPins)
    }
    
    private func mapCityData(cityOverall: CityOverallValues?, citySensors: [Sensor], overallSensorData: [SensorData]) async {
        appData.cityOverall = cityOverall
        appData.citySensors = citySensors
        appData.dailySensorData = overallSensorData
    }
    
    private func getCities() async {
        let cities = await networkService.fetchCities() ?? []
        let overallCities = await networkService.downloadCurrentData(cityNames: cities.map { $0.cityName.lowercased() })
        appData.cities = cities
        appData.cityOverallValues = overallCities
        appData.isWaitingToFetchFavoriteCitiesOveralls = false
    }
    
    private func mapWeeklyAverages() {
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: appData.selectedDate)!
        let threeDaysLater = calendar.date(byAdding: .day, value: +4, to: appData.selectedDate)!
        if let day = appData.selectedDate.getDay, day < 4, let month = appData.selectedDate.getMonth, let year = appData.selectedDate.getYear {
            appData.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                       sensorData: appData.dailySensorData,
                                                                       measures: appData.measures,
                                                                       cityOverall: appData.cityOverall,
                                                                   from: Date.from(1, month, year)!,
                                                                   to: Date.from(8, month, year)!)
            if let today = fetchTodayValue() {
                appData.weeklyData.append(today)
            }
        } else if threeDaysLater < calendar.startOfDay(for: Date.now) {
            appData.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                       sensorData: appData.dailySensorData,
                                                                       measures: appData.measures,
                                                                       cityOverall: appData.cityOverall,
                                                                   from: threeDaysAgo,
                                                                   to: threeDaysLater)
                
            if let today = fetchTodayValue() {
                appData.weeklyData.append(today)
            }
        } else {
            appData.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                       sensorData: appData.dailySensorData,
                                                                       measures: appData.measures,
                                                                       cityOverall: appData.cityOverall,
                                                                   from: calendar.date(byAdding: .day, value: -7, to: Date.now)!,
                                                                   to: calendar.date(byAdding: .day, value: +1, to: Date.now)!)
        }
    }
    
    private func mapMonthlyData(selectedMonth: Int, selectedYear: Int) {
        appData.monthlyData = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                    sensorData: appData.dailySensorData,
                                                                    measures: appData.measures,
                                                                    cityOverall: appData.cityOverall,
                                                           from: Date.from(1, selectedMonth, selectedYear)!,
                                                           to: Date.now)
        if let today = fetchTodayValue() {
            appData.monthlyData.append(today)
        }
    }
    
    private func fetchTodayValue() -> DayDataWrapper? {
        return DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                    sensorData: appData.dailySensorData,
                                                    measures: appData.measures,
                                                    cityOverall: appData.cityOverall,
                                                    from: calendar.startOfDay(for: Date.now),
                                                    to: calendar.date(byAdding: .day, value: +1, to: Date.now)!).first
    }
    
    private func fetchDataForSelectedMonth(cityName: String,
                                           sensorType: String,
                                           selectedMonth: Int,
                                           selectedYear: Int) async -> [SensorData] {
        let endYear = selectedMonth == 12 ? selectedYear + 1 : selectedYear
        let endMonth = selectedMonth == 12 ? 1 : selectedMonth + 1
        
        guard let startDate = Date.from(1, selectedMonth, selectedYear),
              let endDate = Date.from(1, endMonth, endYear) else { return [] }
                
        let result = await networkService.downloadAverageData(for: cityName,
                                                              from: startDate,
                                                              to: endDate,
                                                              timeUnit: .day,
                                                              sensorType: sensorType)
        return result ?? []
    }
}
