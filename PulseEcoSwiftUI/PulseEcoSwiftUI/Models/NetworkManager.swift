//
//  NetworkManager.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/10/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
   
     // MARK: - New
    let language = "lang=\(UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")"
    
    func downloadMeasures() -> AnyPublisher<[Measure], Error> {
            let url = URL(string: "https://pulse.eco/rest/measures?" + language)!
            return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Measure].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
    }
    func downloadSensors(cityName: String) -> AnyPublisher<[SensorModel], Error> {
            let url = URL(string: "https://\(cityName).pulse.eco/rest/sensor")!
            return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SensorModel].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    func downloadOverallValuesForCity(cityName: String) -> AnyPublisher<CityOverallValues, Error> {
            let url = URL(string: "https://\(cityName).pulse.eco/rest/overall")!
            return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CityOverallValues.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    func downloadCurrentDataForSensors(cityName: String) -> AnyPublisher<[Sensor], Error> {
            let url = URL(string: "https://\(cityName).pulse.eco/rest/current")!
            return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Sensor].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    func download24hDataForSensors(cityName: String) -> AnyPublisher<[Sensor], Error> {
            let url = URL(string: "https://\(cityName).pulse.eco/rest/data24h")!
            return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Sensor].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    func downloadCities() -> AnyPublisher<[CityModel], Error> {
        let url = URL(string: "https://skopje.pulse.eco/rest/city")!
                   return URLSession.shared.dataTaskPublisher(for: url)
                   .map(\.data)
                   .decode(type: [CityModel].self, decoder: JSONDecoder())
                   .receive(on: RunLoop.main)
                   .eraseToAnyPublisher()
    }
    func downloadDailyAverageDataForSensor(cityName: String,
                                           measureType: String,
                                           sensorId: String) -> AnyPublisher<[Sensor], Error> {
        
        let from = DateFormatter.iso8601Full.string(from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        let to = DateFormatter.iso8601Full.string(from: Date())
        let requestString = "https://\(cityName).pulse.eco/rest/avgData/day?sensorId=\(sensorId)&type=\(measureType)&from=\(from)&to=\(to)"
        let formattedRequest = requestString.replacingOccurrences(of: "+", with: "%2b")
        let url = URL(string: formattedRequest)!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Sensor].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
