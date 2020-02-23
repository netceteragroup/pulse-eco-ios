import Foundation
import CoreLocation
import PromiseKit

class DataSource {

    static let shared = DataSource()

    // MARK: - New
    var cities: [City] = []
    var measures: [Measure] = []
    var measureValues: [MeasureValue] = MeasureValue.emptyArray()
    var currentMeasure: Measure = Measure.empty()

    // MARK: - OLD
//    var currentReadingType = ReadingType.pm10
    var selectedCityKey: String?
    var allCoordinates: [CLLocation] = []

    // MARK: - Caching methods
    func getMeasures() -> Promise<[Measure]> {
        if measures.count > 0 {
            return Promise.value(measures)
        } else {
            return downloadMeasures()
        }
    }

    func getCities() -> Promise<[City]> {
        if cities.count > 0 {
            return Promise.value(cities)
        } else {
            return downloadCities()
        }
    }

    // MARK: - Download methods
    func downloadCities() -> Promise<[City]> {
        let url = URL(string: "https://bitola.pulse.eco/rest/city")!
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[City]> in
            self.cities = try JSONDecoder().decode([City].self, from: response)
            return Promise.value(self.cities)
        }
    }

    func downloadMeasures() -> Promise<[Measure]> {
        let url = URL(string: "https://pulse.eco/rest/measures")!
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[Measure]> in
            self.measures = try JSONDecoder().decode([Measure].self, from: response)
            return Promise.value(self.measures)
        }
    }

    #warning("DataSource should not bother with current city")
    func downloadValuesForCurrentCity() -> Promise<[SensorReading]> {
        return downloadCurrentValues(for: SharedDataProvider.sharedInstance.selectedCity)
    }

    func downloadCurrentValues(for city: City) -> Promise<[SensorReading]> {
        let url = city.siteUrl.appendingPathComponent("rest/current")
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[SensorReading]> in
            let currentCityValue = try JSONDecoder().decode([SensorReading].self, from: response)
            return Promise.value(currentCityValue)
        }
    }

    func downloadOverall(for city: City) -> Promise<OverallValues> {
        let url = city.siteUrl.appendingPathComponent("rest/overall")
        return getDataFromAPI(baseUrl: url).then { response -> Promise<OverallValues> in
            let overallValueForCity = try JSONDecoder().decode(OverallValues.self, from: response)
            return Promise.value(overallValueForCity)
        }
    }

    func downloadOverallValues() -> Promise<[OverallValues]> {
        let url = urlForOverallValues()
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[OverallValues]> in
            let overallCityValues = try JSONDecoder().decode([OverallValues].self, from: response)
            return Promise.value(overallCityValues)
        }
    }

    func downloadSensors(for city: City) -> Promise<[Sensor]> {
        #warning("""
                    Think of a better way to update values in the currently used data.
                    Maybe separate downloading and storing logic
                 """)
        let url = city.siteUrl.appendingPathComponent("rest/sensor")
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[Sensor]> in
            let sensorsForCity = try JSONDecoder().decode([Sensor].self, from: response)
            var updatedCity = city
            updatedCity.sensors = sensorsForCity
            self.cities.removeAll { $0.key == updatedCity.key }
            self.cities.append(updatedCity)
            return Promise.value(sensorsForCity)
        }
    }

    func sensorReadings(forCity city: City) -> Promise<[SensorReading]> {
        let url = city.siteUrl.appendingPathComponent("rest/data24h")
        return getDataFromAPI(baseUrl: url).then { response -> Promise<[SensorReading]> in
            let sensorReadingsForCity = try JSONDecoder().decode([SensorReading].self, from: response)
            var updatedCity = city
            updatedCity.sensorReadings = sensorReadingsForCity
            self.cities.removeAll { $0.key == updatedCity.key }
            self.cities.append(updatedCity)
            return Promise.value(sensorReadingsForCity)
        }
    }

    // MARK: - Utils
    private func urlForOverallValues() -> URL {
        var urlString = "https://pulse.eco/rest/overall?cityNames="
        cities.forEach { city in
            let cityName = city.name.replacingOccurrences(of: " ", with: "")
            urlString += cityName + ","
        }
        return URL(string: urlString)!
    }

    func invalidateData() {
        cities = []
        selectedCityKey = nil        
    }
}

// MARK: - Closest city
extension DataSource {
    // find the closest city in 50km radius or Skopje by default
    func closestCity(toLocation location: CLLocation?) -> Promise<City> {
        guard location != nil else {
            return Promise.value(City.defaultCity())
        }

        return getCities().then { cities -> Promise<City> in
            let maxDistanceFilter: CLLocationDistance = 50 * 1000; // 50km
            let closestCity = self.closestCity(toLocation: location!,
                                               cities: cities,
                                               maxDistance: maxDistanceFilter)
            return Promise.value(closestCity ?? City.defaultCity())
        }
    }

    private func closestCity(toLocation location: CLLocation, cities: [City], maxDistance: CLLocationDistance) -> City? {
        var closestCity: City?
        var smallestDistance = CLLocationDistanceMax

        for city in cities {
            let cityLocation = CLLocation(latitude: city.coordinates.latitude,
                                          longitude: city.coordinates.longitude)
            let distance = location.distance(from: cityLocation)
            if distance < smallestDistance {
                closestCity = city
                smallestDistance = distance
            }
        }

        if smallestDistance > maxDistance    {
            return nil
        } else {
            return closestCity
        }
    }
}

// MARK: - Private methods
extension DataSource {
    private func getDataFromAPI(baseUrl url: URL) -> Promise<Data> {
        let urlRequest = URLRequest(url: url)

        return Promise { seal in
            executeRequest(request: urlRequest) { data, error in
                if let error = error {
                    seal.reject(error)
                    return
                }

                guard data != nil else {
                    seal.reject(Errors.ServerError)
                    return
                }

                seal.fulfill(data!)
            }
        }
    }

    private func executeRequest(request: URLRequest, completionHandler: @escaping (Data?, Error?)
        -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if error != nil {
                    #warning("This should not be here")
//                    showOverlayMessage(withMessage: noInternetMessage)
                }
                completionHandler(data, error)
            }
        }.resume()
    }
}
