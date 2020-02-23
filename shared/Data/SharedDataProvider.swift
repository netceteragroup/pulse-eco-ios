import Foundation
import PromiseKit

class SharedDataProvider {
    
    static let sharedInstance = SharedDataProvider()
    
    let utilDataProvider = UtilDataProvider()
    
    @UserDefaultCoded("storedSelectedCity") private var storedSelectedCity: City?
    private var selectedCityInMemory: City?
    
    @UserDefault("storedSelectedMeasureId", defaultValue: "pm10") private var storedSelectedMeasureId: String
    private var selectedMeasureIdInMemory: String?
    
    // MARK: - Measure Values
    @UserDefaultCoded("measuresValuesCached") private var storedMeasuresValuesCached: [MeasureValue]?
    private var measuresValuesCachedInMemory: [MeasureValue]?
    
    @UserDefaultOptional("measuresValuesUpdateDate") private var measuresValuesUpdateDate: Date?
    private var measuresValuesUpdateDateInMemory: Date?
    
    var selectedCity: City {
        get {
            if selectedCityInMemory != nil { return selectedCityInMemory! }
            if storedSelectedCity != nil {
                selectedCityInMemory = storedSelectedCity
                return storedSelectedCity!
            }
            return City.defaultCity()
        }
        set {
            DispatchQueue.global(qos: .background).async {
                self.storedSelectedCity = newValue
            }
            selectedCityInMemory = newValue
        }
    }
    
    var selectedMeasureId: String {
        get {
            if selectedMeasureIdInMemory != nil { return selectedMeasureIdInMemory! }
            selectedMeasureIdInMemory = storedSelectedMeasureId
            return storedSelectedMeasureId
        }
        set {
            DispatchQueue.global(qos: .background).async {
                self.storedSelectedMeasureId = newValue
            }
            selectedMeasureIdInMemory = newValue
        }
    }
    
    var measuresValuesCached: [MeasureValue] {
        get {
            if measuresValuesCachedInMemory != nil { return measuresValuesCachedInMemory! }
            if storedMeasuresValuesCached != nil {
                measuresValuesCachedInMemory = storedMeasuresValuesCached
                return storedMeasuresValuesCached!
            }
            return downloadMeasureValues().value ?? MeasureValue.emptyArray()
        }
        set {
            DispatchQueue.global(qos: .background).async {
                self.storedMeasuresValuesCached = newValue
            }
            measuresValuesCachedInMemory = newValue
        }
    }
    
    func downloadMeasureValues() -> Promise<[MeasureValue]> {
        let city = selectedCity
        return firstly {
            return self.utilDataProvider.measureValues(for: city)
        }.then { resultMeasureValues -> Promise<[MeasureValue]> in
            self.measuresValuesCached = resultMeasureValues
            self.measuresValuesUpdateDate = Date()
            return Promise.value(resultMeasureValues)
        }
    }
    
    // Invalidate data needed
}
