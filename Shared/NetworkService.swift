import Foundation
import Combine
import SwiftUI

class NetworkService {
    
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
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [Sensor] = try JSONDecoder().decode([Sensor].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func downloadAverageData(for cityName: String,
                             from startDate: Date,
                             to endDate: Date,
                             timeUnit: AverageTimeUnit,
                             sensorType: String) async -> [SensorData]? {
        let sensorId = -1
        let from = DateFormatter.iso8601Full.string(from: startDate)
        let to = DateFormatter.iso8601Full.string(from: endDate)
        
        let path = "https://\(cityName).pulse.eco/rest/avgData/" +
        "\(timeUnit)?sensorId=\(sensorId)&type=\(sensorType)&from=\(from)&to=\(to)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [SensorData] = try JSONDecoder().decode([SensorData].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func downloadCurrentData(for cityName: String) async -> CityOverallValues? {
        let path = "https://\(cityName).pulse.eco/rest/overall"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: CityOverallValues = try JSONDecoder().decode(CityOverallValues.self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func fetchMeasures() async -> [Measure]? {
        let path = "https://pulse.eco/rest/measures?\(language)"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [Measure] = try JSONDecoder().decode([Measure].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func fetchAndWrapCityData(cityName: String,
                              sensorType: String,
                              selectedDate: Date) async -> CityDataWrapper {
        
        let selectedMonth = calendar.dateComponents([.month], from: selectedDate).month!
        let selectedYear = calendar.dateComponents([.year], from: selectedDate).year!
        
        return await fetchAndWrapCityData(cityName: cityName,
                                          sensorType: sensorType,
                                          selectedMonth: selectedMonth,
                                          selectedYear: selectedYear)
    }
    
    func fetchAndWrapCityData(cityName: String,
                              sensorType: String,
                              selectedMonth: Int,
                              selectedYear: Int) async -> CityDataWrapper {
        
        let currentMonth = calendar.dateComponents([.month], from: Date.now).month!
        let currentYear = calendar.dateComponents([.year], from: Date.now).year!
        
        async let currentMonthSensorData = fetchDataForSelectedMonth(cityName: cityName,
                                                                     sensorType: sensorType,
                                                                     selectedMonth: currentMonth,
                                                                     selectedYear: currentYear)
        
        var allSensorData: [SensorData] = await currentMonthSensorData
        
        if !(selectedYear == currentYear && selectedMonth == currentMonth) {
            async let selectedMonthSensorData = fetchDataForSelectedMonth(cityName: cityName,
                                                                          sensorType: sensorType,
                                                                          selectedMonth: selectedMonth,
                                                                          selectedYear: selectedYear)
            
            await allSensorData.append(contentsOf: selectedMonthSensorData)
            
        }
        
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
        
        let fromDate = calendar.startOfDay(for: from)
        let from = DateFormatter.iso8601Full.string(from: fromDate)
        let to = DateFormatter.iso8601Full.string(from: to)
        
        if Date().isSameDay(with: fromDate) {
            let response = await currentDataSensor(cityName: cityName, measureId: measureId)
            return response
        } else {
            let path = "https://\(cityName).pulse.eco/rest/dataRaw?type=\(measureId)&from=\(from)&to=\(to)"
            let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
            let url = URL(string: formattedRequest)!
            let urlSession = URLSession.shared
            do {
                let (data, _) = try await urlSession.data(from: url)
                let response: [SensorData] = try JSONDecoder().decode([SensorData].self, from: data)
                return response
            } catch {
                return nil
            }
        }
    }
    
    func currentDataSensor (cityName: String, measureId: String) async -> [SensorData]? {
        
        let path = "https://\(cityName).pulse.eco/rest/current"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            var response: [SensorData] = try JSONDecoder().decode([SensorData].self, from: data)
            
            response = response.filter {
                $0.type == measureId
            }
            return response
            
        } catch {
            return nil
        }
    }
    
    func fetchDataForSelectedMonth(cityName: String,
                                   sensorType: String,
                                   selectedMonth: Int,
                                   selectedYear: Int) async -> [SensorData] {
        var newYear = selectedYear
        var newMonth = selectedMonth + 1
        var history: [SensorData] = []
        
        let startDate = Date.from(1, selectedMonth, selectedYear)
        if selectedMonth == 12 {
            newYear += 1
            newMonth = 1
        }
        if selectedMonth == 1 {
            newYear -= 1
            newMonth = 12
        }
        let endDate = Date.from(1, newMonth, newYear)
        let result = await downloadAverageData(for: cityName,
                                               from: startDate!,
                                               to: endDate!,
                                               timeUnit: .day,
                                               sensorType: sensorType)
        
        if let result = result {
            history.append(contentsOf: result)
        }
        return history
    }
    
    func fetch24hDataForSensors(cityName: String) async -> [SensorData]? {
        
        let path = "https://\(cityName).pulse.eco/rest/data24h"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [SensorData] = try JSONDecoder().decode([SensorData].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func fetchCities() async -> [City]? {
        
        let path = "https://skopje.pulse.eco/rest/city"
        let formattedRequest = path.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [City] = try JSONDecoder().decode([City].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
    
    func downloadDailyAverageDataForSensor(cityName: String,
                                           measureType: String,
                                           sensorId: String) async -> [SensorData]? {
        let time = DateFormatter.getTime.string(from: Date())
        var daysAgo: Int {
            time >= "13:00" ? -8 : -7
        }
        let from = DateFormatter.iso8601Full.string(from: calendar.date(byAdding: .day,
                                                                        value: daysAgo,
                                                                        to: Date())!)
        let to = DateFormatter.iso8601Full.string(from: Date())
        let requestString = "https://\(cityName).pulse.eco/rest/avgData/day?sensorId=\(sensorId)&type=\(measureType)&from=\(from)&to=\(to)"
        let formattedRequest = requestString.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        let urlSession = URLSession.shared
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response: [SensorData] = try JSONDecoder().decode([SensorData].self, from: data)
            
            return response
        } catch {
            return nil
        }
    }
}
