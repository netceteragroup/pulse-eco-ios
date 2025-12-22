import Foundation
import Combine
import UIKit
import Factory

protocol AppDataManagerProtocol {
    func getMeasures()
    func startInitialFetch()
    func fetchData(cityName: String, sensorType: String, selectedDate: Date)
    func selectFromCalendar(monthChange: Bool)
    func selectFromDateSlider(selectedDate: Date)
    func selectFromSensorType()
    func getCurrentMeasure(selectedMeasure: String) -> Measure
    func fetchMonthlyDayData(selectedMonth: Int, selectedYear: Int) async
    func updatePins(selectedDate: Date) async
    func updateWeeklyAverageForSensors(selectedDate: Date) async
    func updateMonthlyColors(selectedYear: Int) async
    var onSensorPinsUpdated: PassthroughSubject<[SensorPinModel], Never> { get }
}

class AppDataManager: ObservableObject, AppDataManagerProtocol {
    private let logger = SystemLoggerAdapter(category: "AppDataManager")

    @Injected(\.appData) private var appData: AppDataProtocol
    
    let onSensorPinsUpdated = PassthroughSubject<[SensorPinModel], Never>()
        
    private var measuresTask = Task {}
    
    private let networkService = NetworkService()
    
    func getMeasures() {
        self.appData.loadingMeasures = true
        measuresTask = Task { @MainActor in
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
        fetchData(cityName: UserSettings.selectedCity.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
        getMeasures()
    }
        
    func fetchData(cityName: String, sensorType: String, selectedDate: Date) {
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
    
    func selectFromCalendar(monthChange: Bool) {
        let day = calendar.component(.day, from: appData.selectedDate)
        Task {
            if monthChange || day < 4 {
                let components = calendar.dateComponents([.month, .year, .day], from: appData.selectedDate)
                let selectedMonth = components.month ?? 1
                let selectedYear = components.year ?? 1
                appData.dailySensorData = await fetchDataForSelectedMonth(cityName: UserSettings.selectedCity.cityName,
                                                                           sensorType: appData.selectedMeasureId,
                                                                           selectedMonth: selectedMonth,
                                                                           selectedYear: selectedYear)
            }
            mapWeeklyAverages()
            await updatePins(selectedDate: appData.selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appData.selectedDate)
        }
    }
    
    func selectFromDateSlider(selectedDate: Date) {
        Task {
            await updatePins(selectedDate: selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: selectedDate)
        }
    }
    
    func selectFromSensorType() {
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
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        appData.measures.first { $0.id.lowercased() == selectedMeasure.lowercased() } ?? Measure.empty()
    }
    
    @MainActor
    func fetchMonthlyDayData(selectedMonth: Int, selectedYear: Int) async {
        appData.dailySensorData = await fetchDataForSelectedMonth(cityName: UserSettings.selectedCity.cityName,
                                                          sensorType: appData.selectedMeasureId,
                                                          selectedMonth: selectedMonth,
                                                          selectedYear: selectedYear)
        mapMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
    }
    
    @MainActor
    func updatePins(selectedDate: Date) async {
        guard let to: Date = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) else { return }
        let sensorsData24h =  await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                               measureId: self.appData.selectedMeasureId,
                                                               from: selectedDate,
                                                               to: to) ?? []
        appData.sensorsData24h = sensorsData24h
        let groupById = Dictionary(grouping: sensorsData24h, by: \.sensorID)
        appData.hourlySensors = groupByHour(sensorData: sensorsData24h, groupById: groupById)
        appData.sensorPins = appData.hourlySensors[calendar.component(.hour, from: .now)] ?? []
        appData.selectedDateAverageValue = DataFromRangeMapper.getDataFromRange(sensorType: appData.selectedMeasureId,
                                                                                 sensorData: appData.dailySensorData,
                                                                                 measures: appData.measures,
                                                                                 cityOverall: appData.cityOverall,
                                                                                 from: appData.selectedDate,
                                                                                 to: calendar.date(byAdding: .day, value: +1, to: appData.selectedDate)!).first?.value ?? ""
        onSensorPinsUpdated.send(self.appData.sensorPins)
    }
    
    @MainActor
    func updateWeeklyAverageForSensors(selectedDate: Date) async {
        guard let from = calendar.date(byAdding: .day, value: -7, to: selectedDate) else { return }
        let weeklyAverageForSensors = await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                                       measureId: self.appData.selectedMeasureId,
                                                                       from: from,
                                                                       to: selectedDate) ?? []
        appData.weeklyAverageForSensors = weeklyAverageForSensors
    }
    
    @MainActor
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
                UserSettings.cityValues.removeAll()
                await getCities()
                try? await Task.sleep(nanoseconds: 600 * 1_000_000_000)
            }
        }
    }
    
    private func mapCityData(cityOverall: CityOverallValues?, citySensors: [Sensor], overallSensorData: [SensorData]) async {
        appData.cityOverall = cityOverall
        appData.citySensors = citySensors
        appData.dailySensorData = overallSensorData
    }
    
    private func getCities() async {
        let cities = await networkService.fetchCities() ?? []
        let overallCities = await networkService.downloadCurrentData(cityNames: cities.map { $0.cityName.lowercased() })
        UserSettings.cityValues.append(contentsOf: overallCities)
        appData.isWaitingToFetchFavouriteCitiesOveralls = false
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
            sensorPinModelsByHour[pair.key] = mapSensorPins(sensors: appData.citySensors, sensorsData: result[pair.key]!)
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
    
    private func mapSensorPins(sensors: [Sensor], sensorsData: [SensorData]) -> [SensorPinModel] {
        let selectedMeasure = getCurrentMeasure(selectedMeasure: appData.selectedMeasureId)
        return sensors.flatMap { sensor -> [SensorPinModel] in
            let filteredSensorData = sensorsData.filter { $0.sensorID == sensor.sensorID }
            return filteredSensorData.map { sensorData in
                let color = AppColors.colorFrom(string: selectedMeasure.bands.first { band in
                    Int(sensorData.value) ?? 0 >= band.from && Int(sensorData.value) ?? 0 <= band.to
                }?.legendColor ?? "gray")
                return SensorPinModel(title: sensor.description,
                                                           sensorID: sensor.sensorID,
                                                           measureId: sensorData.type,
                                                           value: sensorData.value,
                                                           position: sensor.position,
                                                           type: sensor.type,
                                                           color: color,
                                                           stamp: sensorData.stamp) }
        }
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
