import Foundation

/// Combination of measures and overall values
struct MeasureValue {
    let value: Int?
    let measure: Measure
    
    var id: String {
        get {
            return measure.id
        }
    }
    
    static func empty() -> MeasureValue {
        return MeasureValue(value: nil, measure: Measure.empty())
    }
    
    static func emptyArray() -> [MeasureValue] {
        var array: [MeasureValue] = []
        for _ in 0...5 {
            array.append(MeasureValue.empty())
        }
        return array
    }
}

extension MeasureValue: Codable {
    private enum MeasureValueCodingKeys: String, CodingKey {
        case value
        case measure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MeasureValueCodingKeys.self)
        value = try container.decode(Int.self, forKey: .value)
        measure = try container.decode(Measure.self, forKey: .measure)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MeasureValueCodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(measure, forKey: .measure)
    }
}
