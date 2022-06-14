import Intents
import Combine

class IntentHandler: INExtension, ConfigurationIntentHandling {
    private let networkService = NetworkService()
    private var subscripitons = Set<AnyCancellable>()
    
    func provideCitiesOptionsCollection(for intent: ConfigurationIntent,
                                        with completion: @escaping (INObjectCollection<CityConfig>?, Error?) -> Void) {
        Task {
            await networkService.fetchCities()
                .map ({ cities in
                    cities
                        .sorted { $0.cityName < $1.cityName}
                        .map { city in
                            CityConfig(identifier: city.cityName,
                                       display: "\(city.cityName), \(city.countryName)")
                        }
                })
        }
    }
    
    func provideMeasuresOptionsCollection(for intent: ConfigurationIntent,
                                          with completion:
                                          @escaping (INObjectCollection<MeasureConfig>?, Error?) -> Void) {
        
        Task {
            await networkService.fetchMeasures()
                .map ({ measures in
                    measures.map { measure in
                        MeasureConfig(identifier: measure.id, display: measure.buttonTitle)
                    }
                })
        }
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}
