import Foundation
import PromiseKit
import CoreLocation

class WidgetDataProvider {
    let utilDataProvider = UtilDataProvider()
    
    // MARK: - Closest City
    @UserDefaultCoded("widgetClosestCity") var closestCity: City?
    
    // MARK: - Selected Measure Value
    @UserDefault("widgetSelectedMeasureID", defaultValue: "pm10") var selectedMeasureID: String
    
    func selectedMeasureValue() -> MeasureValue {
        let selectedMeasureValue = measureValues().first {
            $0.id == selectedMeasureID
        }
        return selectedMeasureValue ?? MeasureValue.empty()
    }
    
    // MARK: - Measure Values
    @UserDefaultCoded("widgetMeasuresValuesCached") var measuresValuesCached: [MeasureValue]?
    @UserDefaultOptional("widgetMeasuresValuesUpdateDate") var measuresValuesUpdateDate: Date?
    
    func measureValues() -> [MeasureValue] {
        return measuresValuesCached ?? MeasureValue.emptyArray()
    }
    
    func downloadMeasureValues(forCurrentLocation currentLocation: CLLocation?) -> Promise<[MeasureValue]> {
        return firstly {
            utilDataProvider.closestCity(toLocation: currentLocation)
        }.then { resultCity -> Promise<[MeasureValue]> in
            self.closestCity = resultCity
            return self.downloadMeasureValues(for: resultCity)
        }
    }
    
    func downloadMeasureValues(for city: City) -> Promise<[MeasureValue]> {
        return firstly {
            return self.utilDataProvider.measureValues(for: city)
        }.then { resultMeasureValues -> Promise<[MeasureValue]> in
            self.measuresValuesCached = resultMeasureValues
            self.measuresValuesUpdateDate = Date()
            return Promise.value(resultMeasureValues)
        }
    }
}
