import Foundation
import Combine
import SwiftUI

class NetworkService {
    private let logger = SystemLoggerAdapter(category: "NetworkService")

    let appURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": "pulse-eco-ios"]
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
    
    // MARK: - New
    var language: String { "lang=\(Trema.appLanguage)" }
    
    enum AverageTimeUnit {
        case day, week, month
    }
    
    func downloadSensorsAsync(cityName: String) async -> [Sensor]? {
        let path = "https://\(cityName).pulse.eco/rest/sensor"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        logger.logDebug("[NetworkService] Request URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([Sensor].self, from: data)
            logger.logDebug("[NetworkService] Download Sendors - Response for: \(cityName)")
            return response
        } catch {
            logger.logError("[NetworkService] Error: \(error.localizedDescription)")
            return nil
        }
    }

    func downloadAverageData(for cityName: String,
                             from startDate: Date,
                             to endDate: Date,
                             timeUnit: AverageTimeUnit,
                             sensorType: String) async -> [SensorData]? {
        let sensorId = -1
        let fromString = DateFormatter.iso8601Full.string(from: startDate)
        let toString = DateFormatter.iso8601Full.string(from: endDate)
        let path = "https://\(cityName).pulse.eco/rest/avgData/\(timeUnit)?sensorId=\(sensorId)&type=\(sensorType)&from=\(fromString)&to=\(toString)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        logger.logDebug("[NetworkService] Request URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            logger.logDebug("[NetworkService] Download average data - Response for city: \(cityName)")
            return response
        } catch {
            logger.logError("[NetworkService] Error: \(error.localizedDescription)")
            return nil
        }
    }

    func downloadCurrentData(for cityName: String) async -> CityOverallValues? {
        let path = "https://\(cityName).pulse.eco/rest/overall"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        logger.logDebug("[NetworkService] Request URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(CityOverallValues.self, from: data)
            logger.logDebug("[NetworkService] Download current data - Response for city: \(cityName)")
            return response
        } catch {
            logger.logError("[NetworkService] Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func downloadCurrentData(cityNames: [String]) async -> [CityOverallValues] {
        let cityNames = cityNames.joined(separator: ",")
        let path = "https://pulse.eco/rest/overall?cityNames=\(cityNames)"
        guard let url = URL(string: path) else { return [] }
        
        logger.logDebug("[NetworkService] Request URL: \(url.absoluteString)")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([CityOverallValues].self, from: data)
            logger.logDebug("[NetworkService] Download current data - Response for cities: \(cityNames)")
            return response
        } catch {
            logger.logError("[NetworkService] Error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchMeasures() async -> [Measure]? {
        let path = "https://pulse.eco/rest/measures?\(language)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        logger.logDebug("[NetworkService] Request URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([Measure].self, from: data)
            logger.logDebug("[NetworkService] Fetched measuers")
            return response
        } catch {
            logger.logError("[NetworkService] Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAndWrapCityData(cityName: String,
                              sensorType: String,
                              selectedDate: Date) async -> CityDataWrapper {
        let components = Calendar.current.dateComponents([.month, .year], from: selectedDate)
        guard let selectedMonth = components.month,
              let selectedYear = components.year else {
            return CityDataWrapper(sensorData: [], currentValue: nil, measures: nil)
        }
        
        return await fetchAndWrapCityData(cityName: cityName,
                                          sensorType: sensorType,
                                          selectedMonth: selectedMonth,
                                          selectedYear: selectedYear)
    }
    
    func fetchAndWrapCityData(cityName: String,
                              sensorType: String,
                              selectedMonth: Int,
                              selectedYear: Int) async -> CityDataWrapper {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.month, .year, .day], from: Date())
        let currentMonth = currentComponents.month ?? 1
        let currentYear = currentComponents.year ?? 1
        let currentDay = currentComponents.day ?? 1
        
        async let currentMonthSensorData = fetchDataForSelectedMonth(cityName: cityName,
                                                                     sensorType: sensorType,
                                                                     selectedMonth: currentMonth,
                                                                     selectedYear: currentYear)
        
        let shouldFetchPreviousMonthData = currentYear == selectedYear && currentMonth == selectedMonth && currentDay < 7
        let previousMonthComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date())
        async let previousMonthSensorData = shouldFetchPreviousMonthData ? await fetchDataForSelectedMonth(cityName: cityName,
                                                                                                           sensorType: sensorType,
                                                                                                           selectedMonth: previousMonthComponents.month ?? 0,
                                                                                                           selectedYear: previousMonthComponents.year ?? 0) : []
        
        let shouldFetchSelectedMonthData = !(selectedYear == currentYear && selectedMonth == currentMonth)
        async let selectedMonthSensorData = shouldFetchSelectedMonthData ? await fetchDataForSelectedMonth(cityName: cityName,
                                                                                                           sensorType: sensorType,
                                                                                                           selectedMonth: selectedMonth,
                                                                                                           selectedYear: selectedYear) : []
        let allSensorData = await currentMonthSensorData + previousMonthSensorData + selectedMonthSensorData
        
        async let current = downloadCurrentData(for: cityName)
        async let measures = fetchMeasures()
        
        return await CityDataWrapper(sensorData: allSensorData,
                                     currentValue: current,
                                     measures: measures)
    }
    
    func fetchSensorData(cityName: String,
                         measureId: String,
                         from: Date,
                         to: Date) async -> [SensorData]? {
        let fromDate = Calendar.current.startOfDay(for: from)
        let fromString = DateFormatter.iso8601Full.string(from: fromDate)
        let toString = DateFormatter.iso8601Full.string(from: to)
        let path = "https://\(cityName).pulse.eco/rest/dataRaw?type=\(measureId)&from=\(fromString)&to=\(toString)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func currentDataSensor(cityName: String, measureId: String) async -> [SensorData]? {
        let path = "https://\(cityName).pulse.eco/rest/current"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            return response.filter { $0.type == measureId }
        } catch {
            return nil
        }
    }
    
    func fetchDataForSelectedMonth(cityName: String,
                                   sensorType: String,
                                   selectedMonth: Int,
                                   selectedYear: Int) async -> [SensorData] {
        var endYear = selectedYear
        var endMonth = selectedMonth + 1
        
        if selectedMonth == 12 {
            endYear += 1
            endMonth = 1
        }
        
        guard let startDate = Date.from(1, selectedMonth, selectedYear),
              let endDate = Date.from(1, endMonth, endYear) else { return [] }
        
        let result = await downloadAverageData(for: cityName,
                                               from: startDate,
                                               to: endDate,
                                               timeUnit: .day,
                                               sensorType: sensorType)
        return result ?? []
    }
    
    func fetch24hDataForSensors(cityName: String) async -> [SensorData]? {
        let path = "https://\(cityName).pulse.eco/rest/data24h"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func fetchCities() async -> [City]? {
        let path = "https://skopje.pulse.eco/rest/city"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([City].self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func fetchCity(cityName: String) async -> City? {
        guard let cities = await fetchCities() else { return nil }
        return cities.first { $0.cityName == cityName }
    }
    
    func downloadDailyAverageDataForSensor(cityName: String,
                                           measureType: String,
                                           sensorId: String) async -> [SensorData]? {
        let time = DateFormatter.getTime.string(from: Date())
        let daysAgo: Int = time >= "13:00" ? -8 : -7
        
        guard let fromDate = Calendar.current.date(byAdding: .day, value: daysAgo, to: Date()) else { return nil }
        let fromString = DateFormatter.iso8601Full.string(from: fromDate)
        let toString = DateFormatter.iso8601Full.string(from: Date())
        
        let path = "https://\(cityName).pulse.eco/rest/avgData/day?sensorId=\(sensorId)&type=\(measureType)&from=\(fromString)&to=\(toString)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func fetchMonthlyAverage(cityName: String,
                             measureType: String,
                             selectedDate: Date) async -> [SensorData]? {
        
        let currentYear = Calendar.current.dateComponents([.year], from: selectedDate).year ?? 0
        guard let from = Date.from(1, 1, currentYear),
              let to = Date.from(31, 12, currentYear) else { return nil }
        
        let fromString = DateFormatter.iso8601Full.string(from: from)
        let toString = DateFormatter.iso8601Full.string(from: to)
        let sensorId = -1
        
        let path = "https://\(cityName).pulse.eco/rest/avgData/month?sensorId=\(sensorId)&type=\(measureType)&from=\(fromString)&to=\(toString)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        guard let url = URL(string: formattedRequest) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([SensorData].self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    func fetchMonthAverages(cityName: String,
                            measureType: String,
                            selectedDate: Date) async -> CityDataWrapper {
        let measures = await fetchMeasures()
        let sensorData = await fetchMonthlyAverage(cityName: cityName,
                                                   measureType: measureType,
                                                   selectedDate: selectedDate)
        return CityDataWrapper(sensorData: sensorData,
                               currentValue: nil,
                               measures: measures)
    }
}
