//
//  SensorMapper.swift
//  PulseEco
//
//  Created by Ljuben Angelkoski on 23.12.25.
//

import Foundation

final class SensorMapper {
    static func groupByHour(sensorData: [SensorData], sensors: [Sensor], selectedMeasure: Measure) -> [Int: [SensorPinModel]] {
        
        struct SensorIdHour: Hashable {
            let hour: Int
            let sensorId: String
        }
        
        var result: [Int: [SensorData]] = [:]
        var seen: Set<SensorIdHour> = []
        let calendar = Calendar.current
        
        for data in sensorData {
            guard let date = DateFormatter.iso8601Full.date(from: data.stamp) else { continue }
            
            let hour = calendar.component(.hour, from: date)
            
            if !seen.contains(SensorIdHour(hour: hour, sensorId: data.sensorID)) {
                seen.insert(SensorIdHour(hour: hour, sensorId: data.sensorID))
                
                if result[hour] == nil {
                    result[hour] = []
                }
                result[hour]?.append(data)
            }
        }
        
        addFor12Pm(result: &result, sensorData: sensorData)
        
        var sensorPinModelsByHour: [Int: [SensorPinModel]] = [:]
        
        for pair in result {
            sensorPinModelsByHour[pair.key] = mapSensorPins(sensors: sensors, sensorsData: result[pair.key]!, selectedMeasure: selectedMeasure)
        }
        
        return sensorPinModelsByHour
    }
    
    private static func addFor12Pm(result: inout [Int: [SensorData]], sensorData: [SensorData]) {
        var seen: Set<String> = []
        
        for sensor in sensorData.reversed() {
            guard let date = DateFormatter.iso8601Full.date(from: sensor.stamp) else { continue }
            let hourAndMinutes = calendar.dateComponents([.hour, .minute], from: date)
            if hourAndMinutes.hour ?? 0 < 23 || hourAndMinutes.minute ?? 0 < 30 {
               break
            }
            if !seen.contains(sensor.sensorID) {
                seen.insert(sensor.sensorID)
                if result[24] == nil {
                    result[24] = []
                }
                result[24]?.append(sensor)
            }
        }
    }
    
    private static func mapSensorPins(sensors: [Sensor], sensorsData: [SensorData], selectedMeasure: Measure) -> [SensorPinModel] {
        sensors.flatMap { sensor -> [SensorPinModel] in
            let filteredSensorData = sensorsData.filter { $0.sensorID == sensor.sensorID }
            return filteredSensorData.map { sensorData in
                let color = AppColors.colorFrom(string: selectedMeasure.bands.first { band in
                    Int(sensorData.value) ?? 0 >= band.from && Int(sensorData.value) ?? 0 <= band.to
                }?.legendColor ?? "gray")
                return SensorPinModel(title: sensor.description,
                                      sensorID: sensor.sensorID,
                                      measureId: sensorData.type,
                                      value: sensorData.value,
                                      position: sensor.position,
                                      type: sensor.type,
                                      color: color,
                                      stamp: sensorData.stamp)
            }
        }
    }
}
