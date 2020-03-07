import Foundation
import PromiseKit

/// Provider for the data from API itself. If has some caching of values that
/// make sense to cache it.
class APIDataProvider {
    
    // MARK: - Overall
    func downloadOverallValues(for city: City) -> Promise<OverallValues> {
        let url = city.siteUrl.appendingPathComponent("rest/overall")

        return Promise { seal in
            firstly {
                URLSession.shared.dataTask(.promise, with: url).validate()
                }.map {
                    try JSONDecoder().decode(OverallValues.self, from: $0.data)
                }.done { result in
                    seal.fulfill(result)
                }.catch { error in
                    seal.reject(error)
            }
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

        return Promise { seal in
            firstly {
                URLSession.shared.dataTask(.promise, with: url).validate()
                }.map {
                    try JSONDecoder().decode([Measure].self, from: $0.data)
                }.done { result in
                    seal.fulfill(result)
                }.catch { error in
                    seal.reject(error)
            }
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
        
        return Promise { seal in
            firstly {
                URLSession.shared.dataTask(.promise, with: url).validate()
                }.map {
                    try JSONDecoder().decode([City].self, from: $0.data)
                }.done { result in
                    self.citiesCached = result
                    self.citiesUpdateDate = Date()
                    seal.fulfill(result)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}
