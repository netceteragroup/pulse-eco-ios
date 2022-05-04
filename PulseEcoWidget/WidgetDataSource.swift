import Foundation
import Combine

typealias WidgetData = (measures: [Measure], cityOverall: CityOverallValues)

class WidgetDataSource {
    static let sharedInstance = WidgetDataSource()
    
    private var cancelables = Set<AnyCancellable>()
    private let networkService = NetworkService()

    func getValuesForCity(cityName: String,
                          measureId: String,
                          completion: @escaping (Result<WidgetData, Error>) -> Void) {
        
        Publishers.Zip(networkService.downloadMeasures(),
                       networkService.downloadOverallValuesForCity(cityName: cityName))
            .sink { downloadCompletion in
                switch downloadCompletion {
                case .failure(let error): completion(.failure(error))
                case .finished: break
                }
            } receiveValue: { (measures, cityOverall) in
                completion(.success((measures, cityOverall)))
            }.store(in: &cancelables)
    }
}
