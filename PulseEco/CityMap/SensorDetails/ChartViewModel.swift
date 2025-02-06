import Foundation
import Charts

class ChartViewModel: ObservableObject {
    @Published var sensor: SensorPinModel
    @Published var sensorsData24h: [SensorData]
    @Published var selectedMeasure: Measure
    //    @Published var sensorReadings: [SensorData]
    @Published var sensorReadings: [ChartSensorReading]
    
    init(sensor: SensorPinModel, sensorsData: [SensorData], selectedMeasure: Measure) {
        self.sensor = sensor
        self.sensorsData24h = sensorsData
        self.selectedMeasure = selectedMeasure
        
        self.sensorReadings = sensorsData.filter {
            $0.sensorID == sensor.sensorID && $0.type == selectedMeasure.id
        }.sorted {
            let date = DateFormatter.iso8601Full.date(from: $0.stamp) ?? Date()
            let date1 = DateFormatter.iso8601Full.date(from: $1.stamp) ?? Date()
            return date < date1
        }.map {
            ChartSensorReading(sensorData: $0)
        }
    }
    
    func maxValue() -> Int {
        let maxValue = sensorReadings.map {
            $0.value
        }.max()
        
        guard let maxValue else { return selectedMeasure.legendMax }
        return maxValue
    }
    
    func minValue() -> Int {
        let minValue = sensorReadings.map {
            $0.value
        }.min()
        
        guard let minValue else { return selectedMeasure.legendMin }
        return minValue < 0 ? minValue : 0
    }
    
    func getASetOfHours() -> [Date] {
        Array(Set(sensorReadings.compactMap {
            calendar.date(bySetting: .minute, value: 0, of: $0.stamp)
        }.compactMap {
            calendar.date(bySetting: .second, value: 0, of: $0)
        }))
    }
    
    func formatTime(for time: Int) -> String {
        let hour = Int(time)
        
        if hour == 12 {
            return "\(hour) PM"
        }
        else if hour == 0 || hour == 24 {
            return "12 AM"
        }
        
        let displayTime = hour % 12
        
        return hour > 12 ? "\(displayTime) PM" : "\(displayTime) AM"
    }
}

struct ChartSensorReading: Identifiable {
    let id = UUID()
    let stamp: Date
    let value: Int
    
    init(sensorData: SensorData) {
        stamp = DateFormatter.iso8601Full.date(from: sensorData.stamp) ?? Date()
        value = Int(sensorData.value) ?? 0
    }
}
