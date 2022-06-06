//
//  CityDataWrapperModel.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 10.5.22.
//

import Foundation

@MainActor
class CityDataWrapper: ObservableObject {
    
    var sensorData: [SensorData]?
    var currentValue: CityOverallValues?
    var measures: [Measure]?
    
    init (sensorData: [SensorData]?, currentValue: CityOverallValues?, measures: [Measure]?) {
        self.sensorData = sensorData
        self.currentValue = currentValue
        self.measures = measures
    }
    
    func getDataFromRange(cityName: String,
                          sensorType: String,
                          from: Date,
                          to: Date) -> [DayDataWrapper] {
        let measure = measures?.first { $0.id == sensorType }
        
        guard let measure = measure, let sensorData = sensorData else {
            return []
        }
        
        var arraySensorData: [SensorData] = (sensorData.filter {
            guard let date = $0.getDate() else {
                return false
            }
            return date >= from && date <= to
        })
        
        arraySensorData = arraySensorData.filter { $0.type == sensorType }
        
        var history: [DayDataWrapper] = arraySensorData.compactMap {
            guard let date = $0.getDate(), let value = Int($0.value), let color = measure.bands.color(for: value) else {
                return nil
            }
            return DayDataWrapper(date: date, value: $0.value, color: color)
        }
        if Date.now >= from && Date.now <= to,
           let today = currentValue?.values[sensorType],
           let color = measure.bands.color(for: Int(today)) {
            history.append(DayDataWrapper(date: Date.now, value: today, color: color))
        }
        print(sensorData)
        return history
    }
}
