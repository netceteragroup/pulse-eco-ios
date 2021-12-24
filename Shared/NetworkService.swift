import Foundation
import Combine

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
}
