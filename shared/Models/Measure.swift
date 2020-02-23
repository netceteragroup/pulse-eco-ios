import Foundation
import UIKit

struct Measure {
    let id: String
    let buttonTitle: String
    let title: String
    let description: String
    let showMin: Int
    let showMax: Int
    let legendMin: Int
    let legendMax: Int
    let unit: String
    let showMessages: Bool
    let bands: [NewBand]
    
    func color(forValue value: Int?) -> UIColor {
        return self.band(forValue: value)?.legendColor ?? UIColor.gray
    }
    
    func shortGrade(forValue value: Int?) -> String {
        return self.band(forValue: value)?.shortGrade ?? "--"
    }
    
    private func band(forValue value: Int?) -> NewBand? {
        return bands.first { $0.valueInBand(value: value) }
    }
    
    static func empty() -> Measure {
        return Measure(id: "--",
                       buttonTitle: "--",
                       title: "--",
                       description: "--",
                       showMin: 0,
                       showMax: NSIntegerMax,
                       legendMin: 0,
                       legendMax: 100,
                       unit: "--",
                       showMessages: false,
                       bands: [NewBand.empty()])
    }
}

extension Measure: Codable {
    private enum MeasureCodingKeys: String, CodingKey {
        case id
        case buttonTitle
        case title
        case description
        case showMin
        case showMax
        case legendMin
        case legendMax
        case unit
        case showMessages
        case bands
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: MeasureCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        buttonTitle = try values.decode(String.self, forKey: .buttonTitle)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        showMin = try values.decode(Int.self, forKey: .showMin)
        showMax = try values.decode(Int.self, forKey: .showMax)
        legendMin = try values.decode(Int.self, forKey: .legendMin)
        legendMax = try values.decode(Int.self, forKey: .legendMax)
        unit = try values.decode(String.self, forKey: .unit)
        showMessages = try values.decode(Bool.self, forKey: .showMessages)
        bands = try values.decode([NewBand].self, forKey: .bands)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MeasureCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(buttonTitle, forKey: .buttonTitle)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(showMin, forKey: .showMin)
        try container.encode(showMax, forKey: .showMax)
        try container.encode(legendMin, forKey: .legendMin)
        try container.encode(legendMax, forKey: .legendMax)
        try container.encode(unit, forKey: .unit)
        try container.encode(showMessages, forKey: .showMessages)
        try container.encode(bands, forKey: .bands)
    }
}

// Here to satisfy the migration from ReadingType
extension Measure {
    
    func sliderValuesAndMultiplier(average: Double) -> ([CGFloat], Double) {
        var multiplier = 1.0

        if self.isHugeValue(average: average) {
            multiplier = multiplierForHugeValues(average: average)
            return (sliderValues(multiplier: multiplier), multiplier)
        } else {
            multiplier = self.multiplier(average: average)
            return (sliderValues(), multiplier)
        }
    }
    
    func multiplier(average: Double) -> Double {
        if id == "pm10" { return average / 210 }
        if id == "pm25" { return average / 125 }
        if id == "noise" { return average / 160 }
        if id == "temperature" { return (average + 15) / 60 }
        if id == "humidity" { return average / 100 }
        if id == "pressure" { return (average - 600) / 600 }
        return 1
    }
    
    func multiplierForHugeValues(average: Double) -> Double {
        if id == "pm10" { return 210 / average }
        if id == "pm25" { return 125 / average }
        if id == "noise" { return 160 / average }
        if id == "temperature" { return 60 / (average + 15) }
        if id == "humidity" { return average / 100 }
        if id == "pressure" { return 600 / (average - 600) }
        return 1
    }
    
    func sliderValues(multiplier: Double = 1.0) -> [CGFloat] {
        if id == "pm10" {
            return [CGFloat(0.12 * multiplier),
                    CGFloat(0.12 * multiplier),
                    CGFloat(0.19 * multiplier),
                    CGFloat(0.423 * multiplier),
                    0.8]
        }
        if id == "pm25" {
            return [CGFloat(0.12 * multiplier),
                    CGFloat(0.12 * multiplier),
                    CGFloat(0.2 * multiplier),
                    CGFloat(0.44 * multiplier),
                    0.8]
        }
        if id == "noise" {
            return [CGFloat(0.125 * multiplier),
                    CGFloat(0.125 * multiplier),
                    CGFloat(0.125 * multiplier),
                    CGFloat(0.156 * multiplier),
                    CGFloat(0.34 * multiplier),
                    0.8]
        }
        if id == "temperature" {
            return [CGFloat(0.167 * multiplier),
                    CGFloat(0.183 * multiplier),
                    CGFloat(0.15 * multiplier),
                    CGFloat(0.117 * multiplier),
                    CGFloat(0.133 * multiplier),
                    CGFloat(0.1 * multiplier),
                    0.8]
        }
        if id == "humidity" {
            return [0.3, 0.4, 0.3]
        }
        if id == "pressure" {
            return [CGFloat(0.33 * multiplier),
                    CGFloat(0.167 * multiplier),
                    CGFloat(0.083 * multiplier),
                    CGFloat(0.083 * multiplier),
                    CGFloat(0.083 * multiplier),
                    0.8]
        }
        return []
    }
    
    func isHugeValue(average: Double) -> Bool {
        if id == "humidity" { return false }
        return Int(average) > legendMax
    }
    
    func sliderColors() -> [UIColor] {
        if id == "pm10" || id == "pm25" {
            return [AppColors.green,
                    AppColors.darkgreen,
                    AppColors.orange,
                    AppColors.red,
                    AppColors.darkred]
        }
        if id == "noise" {
            return [AppColors.green,
                    AppColors.darkgreen,
                    AppColors.orange,
                    AppColors.red,
                    AppColors.darkred,
                    AppColors.purple]
        }
        if id == "temperature" {
            return [AppColors.darkblue,
                    AppColors.blue,
                    AppColors.darkgreen,
                    AppColors.green,
                    AppColors.orange,
                    AppColors.red,
                    AppColors.darkred]
        }
        if id == "humidity" {
            return [AppColors.orange,
                    AppColors.green,
                    AppColors.blue]
        }
        if id == "pressure" {
            return [AppColors.darkblue,
                    AppColors.blue,
                    AppColors.darkgreen,
                    AppColors.green,
                    AppColors.orange,
                    AppColors.red]
        }
        return []
    }
    
    func message(forValue value: Double) -> String {
        return band(forValue: Int(value))?.grade ?? "--"
    }
    
    func midSentenceValue() -> String {
        return title
    }
}


//{
//    "id": "pm25",
//    "buttonTitle": "PM25",
//    "title": "Air quality (PM25)",
//    "icon": "fa fa-cloud icon-pm25",
//    "description": "Suspended particulate matter in air less than 2.5μm wide.",
//    "showMin": 0,
//    "showMax": 50,
//    "legendMin": 0,
//    "legendMax": 110,
//    "unit": "μg/m3",
//    "showMessages": true,
//    "bands":


//    [
//    {
//    "from": 0,
//    "to": 15,
//    "legendPoint": 0,
//    "legendColor": "green",
//    "markerColor": "green",
//    "shortGrade": "Good air quality.",
//    "grade": "Good air quality. Air quality is considered satisfactory, and air pollution poses little or no risk",
//    "suggestion": "No preventive measures needed, enjoy the fresh air."
//    },
//    {
//    "from": 16,
//    "to": 30,
//    "legendPoint": 23,
//    "legendColor": "darkgreen",
//    "markerColor": "darkgreen",
//    "shortGrade": "Moderate air quality.",
//    "grade": "Moderate air quality. Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people.",
//    "suggestion": "Consider limiting your outside exposure if you're sensitive to bad air."
//    },
//    {
//    "from": 31,
//    "to": 55,
//    "legendPoint": 45,
//    "legendColor": "orange",
//    "markerColor": "orange",
//    "shortGrade": "Bad air quality.",
//    "grade": "Bad air quality. Unhealthy for Sensitive Groups, people with lung disease, older adults and children.",
//    "suggestion": "Limit your outside exposure if you're sensitive to bad air."
//    },
//    {
//    "from": 56,
//    "to": 110,
//    "legendPoint": 83,
//    "legendColor": "red",
//    "markerColor": "red",
//    "shortGrade": "Very bad air quality.",
//    "grade": "Very bad air quality. Everyone may begin to experience some adverse health effects, and members of the sensitive groups may experience more serious effects.",
//    "suggestion": "Stay indoors if you're sensitive to bad air. Everyone should limit outside exposure"
//    },
//    {
//    "from": 111,
//    "to": 1000,
//    "legendPoint": 110,
//    "legendColor": "darkred",
//    "markerColor": "darkred",
//    "shortGrade": "Hazardous air quality!",
//    "grade": "Hazardous air quality! This would trigger a health warnings of emergency conditions. The entire population is more likely to be affected!",
//    "suggestion": "Stay indoors as much as possible."
//    }
//    ]
//}
