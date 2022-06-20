import Foundation
import Combine

typealias WidgetData = (measures: [Measure], cityOverall: CityOverallValues)

class WidgetDataSource {
    static let sharedInstance = WidgetDataSource()
    
    private var cancelables = Set<AnyCancellable>()
    private let networkService = NetworkService()

    func getValuesForCity(cityName: String,
                          measureId: String) async -> WidgetData? {
        
        async let measures = networkService.fetchMeasures()
        async let cityOverall = networkService.downloadCurrentData(for: cityName)
        guard let measures = await measures, let cityOverall = await cityOverall else {
            return nil
        }
        
        return WidgetData(measures, cityOverall)
    }
}
