import Foundation

func combine(overallValues: OverallValues, measures: [Measure]) -> [MeasureValue] {
    let measureIds = measures.map { measure in
        measure.id
    }
    let overallValuesIds = overallValues.values.keys
    
    let commonIds = measureIds.filter(overallValuesIds.contains)
    
    let commonMeasures = measures.filter { commonIds.contains($0.id) }
    let commonValues = commonIds.map { Int(overallValues.values[$0]!)! }

    return zip(commonValues, commonMeasures).map { MeasureValue(value: $0, measure: $1) }
}

