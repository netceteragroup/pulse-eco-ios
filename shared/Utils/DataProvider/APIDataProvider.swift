import Foundation
import PromiseKit

/// Provider for the data from API itself. If has some caching of values that
/// make sense to cache it.
class APIDataProvider {
    private let promiseKitWrapper = PromiseKitWrapper()
    
    // MARK: - Overall
    func downloadOverallValues(for city: City) -> Promise<OverallValues> {
        let url = city.siteUrl.appendingPathComponent("rest/overall")
        return promiseKitWrapper.getDataFromAPI(baseUrl: url).then { response -> Promise<OverallValues> in
            let overallValueForCity = try JSONDecoder().decode(OverallValues.self, from: response)
            return Promise.value(overallValueForCity)
        }
    }
    
    // MARK: - Measures
    private let measuresMaxAge: TimeInterval = 24 * 3600 // 24h
    @UserDefaultCoded("measuresCached") private var measuresCached: [Measure]?
    @UserDefaultOptional("measuresUpdateDate") private var measuresUpdateDate: Date?
    
    func measures() -> Promise<[Measure]> {
        if measuresCached == nil {
            return downloadMeasures()
        }
        guard let measuresUpdateDate = self.measuresUpdateDate else {
            return downloadMeasures()
        }
        if abs(measuresUpdateDate.timeIntervalSinceNow) > measuresMaxAge {
            return downloadMeasures()
        }
        return Promise.value(measuresCached!)
    }
    
    private func downloadMeasures() -> Promise<[Measure]> {
        let url = URL(string: "https://pulse.eco/rest/measures")!
        return promiseKitWrapper.getDataFromAPI(baseUrl: url).then { response -> Promise<[Measure]> in
            let measures = try JSONDecoder().decode([Measure].self, from: response)
            self.measuresCached = measures
            self.measuresUpdateDate = Date()
            return Promise.value(measures)
        }
    }

    // MARK: - Cities
    private let citiesMaxAge: TimeInterval = 24 * 3600 // 24h
    @UserDefaultCoded("citiesCached") private var citiesCached: [City]?
    @UserDefaultOptional("citiesUpdateDate") private var citiesUpdateDate: Date?
    
    func cities() -> Promise<[City]> {
        if citiesCached == nil {
            return downloadCities()
        }
        guard let citiesUpdateDate = self.citiesUpdateDate else {
            return downloadCities()
        }
        if abs(citiesUpdateDate.timeIntervalSinceNow) > citiesMaxAge {
            return downloadCities()
        }
        return Promise.value(citiesCached!)
    }
    
    private func downloadCities() -> Promise<[City]> {
        let url = URL(string: "https://bitola.pulse.eco/rest/city")!
        return promiseKitWrapper.getDataFromAPI(baseUrl: url).then { response -> Promise<[City]> in
            let cities = try JSONDecoder().decode([City].self, from: response)
            self.citiesCached = cities
            self.citiesUpdateDate = Date()
            return Promise.value(cities)
        }
    }
}
