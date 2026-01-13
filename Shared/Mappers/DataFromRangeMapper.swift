//
//  DataFromRangeMapper.swift
//  PulseEco
//
//  Created by Ljuben Angelkoski on 16.12.25.
//

import Foundation

final class DataFromRangeMapper {
    static func getDataFromRange(sensorType: String,
                                 sensorData: [SensorData],
                                 measures: [Measure],
                                 cityOverall: CityOverallValues?,
                                 from: Date,
                                 to: Date) -> [DayDataWrapper] {
        let measure = measures.first { $0.id == sensorType }
        
        guard let measure = measure else {
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
           let today = cityOverall?.values[sensorType],
           let color = measure.bands.color(for: Int(today)) {
            history.append(DayDataWrapper(date: Date.now, value: today, color: color))
        }
        
        return Array(Set(history)).sorted {
            $0.date < $1.date
        }
    }
}
