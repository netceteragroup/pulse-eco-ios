import Intents
import Combine

class IntentHandler: INExtension, ConfigurationIntentHandling {
    private let networkService = NetworkService()
    private var subscripitons = Set<AnyCancellable>()
    
    func provideCitiesOptionsCollection(for intent: ConfigurationIntent,
                                        with completion: @escaping (INObjectCollection<CityConfig>?, Error?) -> Void) {
        
        networkService.downloadCities()
            .replaceError(with: [City.defaultCity()])
            .map { cities in
                cities
                    .sorted { $0.siteName < $1.siteName }
                    .map { city in
                        CityConfig(identifier: city.cityName, display: "\(city.siteName), \(city.countryName)")
                    }
            }
            .sink(receiveValue: { cityConfigs in
                let items = INObjectCollection(items: cityConfigs)
                completion(items, nil)
            })
            .store(in: &subscripitons)
    }
    
    func provideMeasuresOptionsCollection(for intent: ConfigurationIntent,
                                          with completion:
                                          @escaping (INObjectCollection<MeasureConfig>?, Error?) -> Void) {
        networkService.downloadMeasures()
            .replaceError(with: [Measure.empty()])
            .map({ measures in
                measures.map { measure in
                    MeasureConfig(identifier: measure.id, display: measure.buttonTitle)
                }
            })
            .sink(receiveValue: { measureConfigs in
                let items = INObjectCollection(items: measureConfigs)
                completion(items, nil)
            })
            .store(in: &subscripitons)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}
