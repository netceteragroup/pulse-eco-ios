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
    
    func downloadMeasures() -> AnyPublisher<[Measure], Error> {
            let url = URL(string: "https://pulse.eco/rest/measures")!
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
}

