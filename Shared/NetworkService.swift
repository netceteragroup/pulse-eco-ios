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
    
    func downloadMeasures() -> AnyPublisher<[Measure], Error> {
        let url = URL(string: "https://pulse.eco/rest/measures?\(language)")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Measure].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func downloadSensors(cityName: String) -> AnyPublisher<[Sensor], Error> {
        let url = URL(string: "https://\(cityName).pulse.eco/rest/sensor")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Sensor].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func downloadOverallValuesForCity(cityName: String) -> AnyPublisher<CityOverallValues, Error> {
        let url = URL(string: "https://\(cityName).pulse.eco/rest/overall")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CityOverallValues.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func downloadCurrentDataForSensors(cityName: String) -> AnyPublisher<[SensorData], Error> {
        let url = URL(string: "https://\(cityName).pulse.eco/rest/current")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SensorData].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func download24hDataForSensors(cityName: String) -> AnyPublisher<[SensorData], Error> {
        let url = URL(string: "https://\(cityName).pulse.eco/rest/data24h")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SensorData].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func downloadCities() -> AnyPublisher<[City], Error> {
        let url = URL(string: "https://skopje.pulse.eco/rest/city")!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [City].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    //    The request returns timestamp for the average data records exactly at noon GMT of the target day
    //    i.e exactly at 13:00
    //    if the request is made before 13h and the daysAgo's value is set to -7, it returns exactly seven values
    //    counting from yesterday's date
    //    for some reason if the request is made after 13h and the daysAgo's value is set to -7, it returns values for
    //    exactly six days from yesterday's date,
    //    that's why daysAgo in this case is set to -8, so we can have data for the past seven days
    func downloadDailyAverageDataForSensor(cityName: String,
                                           measureType: String,
                                           sensorId: String) -> AnyPublisher<[SensorData], Error> {
        let time = DateFormatter.getTime.string(from: Date())
        var daysAgo: Int {
            time >= "13:00" ? -8 : -7
        }
        let from = DateFormatter.iso8601Full.string(from: Calendar.current.date(byAdding: .day,
                                                                                value: daysAgo,
                                                                                to: Date())!)
        let to = DateFormatter.iso8601Full.string(from: Date())
        let baseString = "https://\(cityName).pulse.eco/"
        let path = "rest/avgData/day?sensorId=\(sensorId)&type=\(measureType)&from=\(from)&to=\(to)"
        let requestString = baseString + path
        let formattedRequest = requestString.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        return appURLSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SensorData].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
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
    
    enum AverageTimeUnit {
        case day, week, month
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
    
//    func downloadAverageDayData(for cityName: String,
//                                sensorType: String) async -> [SensorData] {
//        var history: [SensorData] = []
//        let components = Calendar.current.dateComponents([.year], from: Date())
//        let year = components.year!
//        for var year in 2016...year {
//            
//            let startDate = Date.from(1, 1, year)!
//            let endDate = Date.from(1, 1, year+1)!
//            let result = await downloadAverageData(for: cityName,
//                                                   from: startDate,
//                                                   to: endDate,
//                                                   timeUnit: .day,
//                                                   sensorType: sensorType)
//            year += 1
//            if let result = result {
//                history.append(contentsOf: result)
//            }
//        }
//        return history
//    }
    
    func downloadMeasures() async -> [Measure]? {
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
    
    func downloadOverallCurrentMeasures(cityName: String,
                                        sensorType: String,
                                        selectedDate: Date) async -> CityDataWrapper {
        
        let selectedMonth = Calendar.current.dateComponents([.month], from: selectedDate).month!
        let selectedYear = Calendar.current.dateComponents([.year], from: selectedDate).year!
        
        return await downloadOverallCurrentMeasures(cityName: cityName,
                                                    sensorType: sensorType,
                                                    selectedMonth: selectedMonth,
                                                    selectedYear: selectedYear)
    }
    
    func downloadOverallCurrentMeasures(cityName: String,
                                        sensorType: String,
                                        selectedMonth: Int,
                                        selectedYear: Int) async -> CityDataWrapper {
        
        async let history = fetchDataForSelectedMonth(cityName: cityName,
                                                      sensorType: sensorType,
                                                      selectedMonth: selectedMonth,
                                                      selectedYear: selectedYear)
        async let current = downloadCurrentData(for: cityName)
        async let measures = downloadMeasures()
        
        return await CityDataWrapper(sensorData: history,
                                     currentValue: current,
                                     measures: measures)
    }
    
    func downloadSensorData(cityName: String,
                            measureId: String,
                            from: Date,
                            to: Date) async -> [SensorData]? {
        
        let fromDate = Calendar.current.startOfDay(for: from)
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
    
}
extension Date {
    static func from(_ day: Int, _ month: Int, _ year: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 00
        dateComponents.minute = 00
        dateComponents.second = 00
        dateComponents.timeZone = TimeZone(secondsFromGMT: 7200)
        return calendar.date(from: dateComponents) ?? nil
    }
    
    func isSameDay(with date: Date) -> Bool {
        let components1 = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let components2 = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return components1 == components2
    }
}
