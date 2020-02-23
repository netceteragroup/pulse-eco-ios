import Foundation
import PromiseKit
import CoreLocation

/// Data provider one level over the APIDataProvider, where we have util and combination methods
class UtilDataProvider {
    private let apiDataProvider = APIDataProvider()
    
    // MARK: - Measure Values
    func measureValues(for city: City) -> Promise<[MeasureValue]> {
        var measures: [Measure]?
        return firstly {
            return self.apiDataProvider.measures()
        }.then { resultMeasures -> Promise<OverallValues> in
            measures = resultMeasures
            return self.apiDataProvider.downloadOverallValues(for: city)
        }.then { resultOverallValues -> Promise<[MeasureValue]> in
            let measureValues = combine(overallValues: resultOverallValues, measures: measures!)
            return Promise.value(measureValues)
        }
    }
    
    // MARK: - Closest City
    func closestCity(toLocation location: CLLocation?) -> Promise<City> {
        guard location != nil else {
            return Promise.value(City.defaultCity())
        }
        
        return apiDataProvider.cities().then { cities -> Promise<City> in
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
