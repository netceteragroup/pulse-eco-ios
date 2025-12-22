import Foundation
import Combine
import UIKit

@MainActor
class AppDataSource: ObservableObject {
    private let logger = SystemLoggerAdapter(category: "AppDataSource")

    private let appState: AppState
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
    
    let onSensorPinsUpdated = PassthroughSubject<[SensorPinModel], Never>()
        
    private var measuresTask = Task {}
    
    private let networkService = NetworkService()
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func getMeasures() {
        self.appState.loadingMeasures = true
        measuresTask = Task {
            self.measures = await networkService.fetchMeasures() ?? []
            if let firstMeasureId = measures.first?.id {
                self.appState.selectedMeasureId = firstMeasureId
            }
            self.appState.loadingMeasures = false
        }
    }
    
    func startInitialFetch() {
        scheduleFetchCitiesOnRepeat()
        fetchData(cityName: UserSettings.selectedCity.cityName, sensorType: appState.selectedMeasureId, selectedDate: appState.selectedDate)
        getMeasures()
    }
        
    func fetchData(cityName: String, sensorType: String, selectedDate: Date) {
        logger.logDebug("Fetching values for city: \(cityName)")
        guard let selectedMonth = selectedDate.getMonth,
              let selectedYear = selectedDate.getYear else { return }
        Task {
            self.appState.loadingCityData = true
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
            
            await updatePins(selectedDate: appState.selectedDate)
            self.appState.loadingCityData = false
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appState.selectedDate)
        }
    }
    
    func selectFromCalendar(monthChange: Bool) {
        let day = calendar.component(.day, from: appState.selectedDate)
        Task {
            if monthChange || day < 4 {
                let components = calendar.dateComponents([.month, .year, .day], from: appState.selectedDate)
                let selectedMonth = components.month ?? 1
                let selectedYear = components.year ?? 1
                dailySensorData = await fetchDataForSelectedMonth(cityName: UserSettings.selectedCity.cityName,
                                                                  sensorType: appState.selectedMeasureId,
                                                                  selectedMonth: selectedMonth,
                                                                  selectedYear: selectedYear)
            }
            mapWeeklyAverages()
            await updatePins(selectedDate: appState.selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appState.selectedDate)
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
        let components = Calendar.current.dateComponents([.month, .year], from: appState.selectedDate)
        guard let selectedMonth = components.month,
              let selectedYear = components.year else { return }
        Task {
            await fetchMonthlyDayData(selectedMonth: selectedMonth, selectedYear: selectedYear)
            mapWeeklyAverages()
            await updatePins(selectedDate: appState.selectedDate)
        }
        Task {
            await updateWeeklyAverageForSensors(selectedDate: appState.selectedDate)
        }
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        measures.first { $0.id.lowercased() == selectedMeasure.lowercased() } ?? Measure.empty()
    }
    
    func fetchMonthlyDayData(selectedMonth: Int, selectedYear: Int) async {
        dailySensorData = await fetchDataForSelectedMonth(cityName: UserSettings.selectedCity.cityName,
                                                          sensorType: appState.selectedMeasureId,
                                                          selectedMonth: selectedMonth,
                                                          selectedYear: selectedYear)
        mapMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
    }
    
    func updatePins(selectedDate: Date) async {
        guard let to: Date = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) else { return }
        sensorsData24h =  await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                               measureId: self.appState.selectedMeasureId,
                                                               from: selectedDate,
                                                               to: to) ?? []
        let groupById = Dictionary(grouping: sensorsData24h, by: \.sensorID)
        appState.hourlySensors = groupByHour(sensorData: sensorsData24h, groupById: groupById)
        appState.sensorPins = appState.hourlySensors[calendar.component(.hour, from: .now)] ?? []
        appState.selectedDateAverageValue = DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                                                 sensorData: dailySensorData,
                                                                                 measures: measures,
                                                                                 cityOverall: cityOverall,
                                                                                 from: appState.selectedDate,
                                                                                 to: calendar.date(byAdding: .day, value: +1, to: appState.selectedDate)!).first?.value ?? ""
        onSensorPinsUpdated.send(self.appState.sensorPins)
    }
    
    func updateWeeklyAverageForSensors(selectedDate: Date) async {
        guard let from = calendar.date(byAdding: .day, value: -7, to: selectedDate) else { return }
        weeklyAverageForSensors = await networkService.fetchSensorData(cityName: UserSettings.selectedCity.cityName,
                                                                       measureId: self.appState.selectedMeasureId,
                                                                       from: from,
                                                                       to: selectedDate) ?? []
    }
    
    func updateMonthlyColors(selectedYear: Int) async {
        guard let from = Date.from(1, 1, selectedYear),
              let to = Date.from(31, 12, selectedYear) else { return }
        let sensorData = await networkService.fetchMonthlyAverage(cityName: UserSettings.selectedCity.cityName,
                                                                  measureType: self.appState.selectedMeasureId,
                                                                  selectedDate: from)
        monthlyAverage = DataFromRangeMapper.getDataFromRange(sensorType: self.appState.selectedMeasureId,
                                                              sensorData: sensorData ?? [],
                                                              measures: measures,
                                                              cityOverall: cityOverall,
                                                              from: from,
                                                              to: to)
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
        self.cityOverall = cityOverall
        self.citySensors = citySensors
        self.dailySensorData = overallSensorData
    }
    
    private func getCities() async {
        let cities = await networkService.fetchCities() ?? []
        let overallCities = await networkService.downloadCurrentData(cityNames: cities.map { $0.cityName.lowercased() })
        UserSettings.cityValues.append(contentsOf: overallCities)
        appState.isWaitingToFetchFavouriteCitiesOveralls = false
    }
    
    private func mapWeeklyAverages() {
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: appState.selectedDate)!
        let threeDaysLater = calendar.date(byAdding: .day, value: +4, to: appState.selectedDate)!
        if let day = appState.selectedDate.getDay, day < 4, let month = appState.selectedDate.getMonth, let year = appState.selectedDate.getYear {
            self.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                                   sensorData: dailySensorData,
                                                                   measures: measures,
                                                                   cityOverall: cityOverall,
                                                                   from: Date.from(1, month, year)!,
                                                                   to: Date.from(8, month, year)!)
            if let today = fetchTodayValue() {
                self.weeklyData.append(today)
            }
        } else if threeDaysLater < calendar.startOfDay(for: Date.now) {
            self.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                                   sensorData: dailySensorData,
                                                                   measures: measures,
                                                                   cityOverall: cityOverall,
                                                                   from: threeDaysAgo,
                                                                   to: threeDaysLater)
                
            if let today = fetchTodayValue() {
                self.weeklyData.append(today)
            }
        } else {
            self.weeklyData = DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                                   sensorData: dailySensorData,
                                                                   measures: measures,
                                                                   cityOverall: cityOverall,
                                                                   from: calendar.date(byAdding: .day, value: -7, to: Date.now)!,
                                                                   to: calendar.date(byAdding: .day, value: +1, to: Date.now)!)
        }
    }
    
    private func mapMonthlyData(selectedMonth: Int, selectedYear: Int) {
        monthlyData = DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                           sensorData: dailySensorData,
                                                           measures: measures,
                                                           cityOverall: cityOverall,
                                                           from: Date.from(1, selectedMonth, selectedYear)!,
                                                           to: Date.now)
        if let today = fetchTodayValue() {
            monthlyData.append(today)
        }
    }
    
    private func fetchTodayValue() -> DayDataWrapper? {
        return DataFromRangeMapper.getDataFromRange(sensorType: appState.selectedMeasureId,
                                                    sensorData: dailySensorData,
                                                    measures: measures,
                                                    cityOverall: cityOverall,
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
            sensorPinModelsByHour[pair.key] = mapSensorPins(sensors: citySensors, sensorsData: result[pair.key]!)
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
        let selectedMeasure = getCurrentMeasure(selectedMeasure: appState.selectedMeasureId)
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
