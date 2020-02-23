import Foundation
import UIKit

struct NewBand {
    let from: Int
    let to: Int
    let legendPoint: Int
    let legendColor: UIColor
    let markerColor: UIColor
    let shortGrade: String
    let grade: String
    let suggestion: String
    
    func valueInBand(value: Int?) -> Bool {
        guard let value = value else {
            return false
        }
        return value >= from && value <= to
    }
    
    static func empty() -> NewBand {
        return NewBand(from: 0,
                       to: NSIntegerMax,
                       legendPoint: 0,
                       legendColor: AppColors.gray,
                       markerColor: AppColors.gray,
                       shortGrade: "--",
                       grade: "--",
                       suggestion: "--")
    }
}

extension NewBand: Codable {
    
    //{
    //    "from": 0,
    //    "to": 15,
    //    "legendPoint": 0,
    //    "legendColor": "green",
    //    "markerColor": "green",
    //    "shortGrade": "Good air quality.",
    //    "grade": "Good air quality. Air quality is considered satisfactory, and air pollution poses little or no risk",
    //    "suggestion": "No preventive measures needed, enjoy the fresh air."
    //}
    private enum BandCodingKeys: String, CodingKey {
        case from
        case to
        case legendPoint
        case legendColor
        case markerColor
        case showMax
        case shortGrade
        case grade
        case suggestion
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: BandCodingKeys.self)
        from = try values.decode(Int.self, forKey: .from)
        to = try values.decode(Int.self, forKey: .to)
        legendPoint = try values.decode(Int.self, forKey: .legendPoint)
        
        let legendColorString = try values.decode(String.self, forKey: .legendColor)
        legendColor = AppColors.colorFrom(string: legendColorString)
        
        let markerColorString = try values.decode(String.self, forKey: .markerColor)
        markerColor = AppColors.colorFrom(string: markerColorString)
        
        shortGrade = try values.decode(String.self, forKey: .shortGrade)
        grade = try values.decode(String.self, forKey: .grade)
        suggestion = try values.decode(String.self, forKey: .suggestion)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BandCodingKeys.self)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(legendPoint, forKey: .legendPoint)
        try container.encode(AppColors.stringFrom(color: legendColor), forKey: .legendColor)
        try container.encode(AppColors.stringFrom(color: markerColor), forKey: .markerColor)
        try container.encode(shortGrade, forKey: .shortGrade)
        try container.encode(grade, forKey: .grade)
        try container.encode(suggestion, forKey: .suggestion)
    }
}

