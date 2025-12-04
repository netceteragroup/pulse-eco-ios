import Foundation
import SwiftUI
import Charts

class ChartViewModel: ObservableObject {
    @Published var sensor: SensorPinModel
    @Published var sensors: [SensorPinModel]
    @Published var sensorsData24h: [SensorData]
    @Published var selectedMeasure: Measure
    @Published var chartSensorReadings: [[ChartSensorReading]]
    @Published var selectedSensorReadings: [ChartSensorReading]
    
    init(sensor: SensorPinModel, sensors: [SensorPinModel], sensorsData: [SensorData], selectedMeasure: Measure, sensorDataForSelectedDate: [SensorData]) {
        self.sensor = sensor
        self.sensors = sensors
        self.sensorsData24h = sensorsData
        self.selectedMeasure = selectedMeasure
        let dataFromSensors = sensorDataForSelectedDate.isEmpty ? sensorsData : sensorDataForSelectedDate
        chartSensorReadings = []
        
        selectedSensorReadings = dataFromSensors.filter {
            $0.sensorID == sensor.sensorID && $0.type == selectedMeasure.id
        }
        .sorted {
            let date = DateFormatter.iso8601Full.date(from: $0.stamp) ?? Date()
            let date1 = DateFormatter.iso8601Full.date(from: $1.stamp) ?? Date()
            return date < date1
        }.reduce(into: [SensorData]()) { partialResult, nextData in
            if let lastDate = DateFormatter.iso8601Full.date(from: partialResult.last?.stamp ?? ""),
               let date = DateFormatter.iso8601Full.date(from: nextData.stamp) {
                let diff = date.timeIntervalSince(lastDate)
                if diff >= 5 * 60 {
                    partialResult.append(nextData)
                }
            }
            else {
                partialResult.append(nextData)
            }
        }
        .map {
            ChartSensorReading(sensorData: $0, title: sensor.title)
        }
        
        for sensor in sensors {
            let tmp = dataFromSensors.filter {
                $0.sensorID == sensor.sensorID && $0.type == selectedMeasure.id
            }.sorted {
                let date = DateFormatter.iso8601Full.date(from: $0.stamp) ?? Date()
                let date1 = DateFormatter.iso8601Full.date(from: $1.stamp) ?? Date()
                return date < date1
            }.reduce(into: [SensorData]()) { partialResult, nextData in
                if let lastDate = DateFormatter.iso8601Full.date(from: partialResult.last?.stamp ?? ""),
                   let date = DateFormatter.iso8601Full.date(from: nextData.stamp) {
                    let diff = date.timeIntervalSince(lastDate)
                    if diff >= 30 * 60 {
                        partialResult.append(nextData)
                    }
                }
                else {
                    partialResult.append(nextData)
                }
            }
            .map {
                ChartSensorReading(sensorData: $0, title: sensor.title)
            }
            chartSensorReadings.append(tmp)
        }
    }
    
    func maxValue() -> Int {
        let selectedSensorReadingMaxValue = selectedSensorReadings.map({ sensor in
            sensor.value
        }).max()
        
        if let selectedSensorReadingMaxValue {
            return selectedSensorReadingMaxValue
        }
        
        else {
            let chartSensorReadingsMaxValue = chartSensorReadings.joined().compactMap{
                $0.value
            }.max()
            
            if let chartSensorReadingsMaxValue {
                return chartSensorReadingsMaxValue
            }
            
            return selectedMeasure.legendMax
        }
    }
    
    func getMinDate(selectedDate: Date) -> Date {
        let selectedSensorReadingMinDate = selectedSensorReadings.map({ sensor in
            sensor.stamp
        }).min()
        
        if let selectedSensorReadingMinDate {
            return selectedSensorReadingMinDate
        }
        
        let chartSensorReadingsMinDate = chartSensorReadings.joined().compactMap {
            $0.stamp
        }.min()
        
        if let chartSensorReadingsMinDate {
            return chartSensorReadingsMinDate
        }
        
        return getLast24HForGraph(selectedDate: selectedDate).first ?? Date()
    }
    
    func getMaxDate() -> Date {
        
        let selectedSensorReadingMaxDate = selectedSensorReadings.map({ sensor in
            sensor.stamp
        }).max()
        
        if let selectedSensorReadingMaxDate {
            return selectedSensorReadingMaxDate
        }
        
        let chartSensorReadingsMaxDate = chartSensorReadings.joined().compactMap {
            $0.stamp
        }.max()
        
        if let chartSensorReadingsMaxDate {
            return chartSensorReadingsMaxDate
        }
        
        return Date()
    }
    
    func getASetOfDates() -> [Date] {
        Array(Set(chartSensorReadings.joined().compactMap {
            calendar.date(bySetting: .minute, value: 0, of: $0.stamp)
        }.compactMap {
            calendar.date(bySetting: .second, value: 0, of: $0)
        }.sorted()))
    }
    
    func getLast24HForGraph(selectedDate: Date) -> [Date] {
        if selectedDate == Date.now {
            return getLast24H(selectedDate: selectedDate)
        }
        else {
            var date = getMinDate(selectedDate: selectedDate)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            return getLast24H(selectedDate: date)
        }
    }
    
    func getLast24H(selectedDate: Date) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        for i in stride(from: 0, through: 24, by: 4) {
            if let date = calendar.date(byAdding: .hour, value: -i, to: selectedDate) {
                dates.append(date)
            }
        }
        
        return dates.reversed()
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

struct ChartSensorReading: Identifiable, Hashable {
    let id = UUID()
    let stamp: Date
    let value: Int
    let title: String
    
    init(sensorData: SensorData, title: String?) {
        stamp = DateFormatter.iso8601Full.date(from: sensorData.stamp) ?? Date()
        value = Int(sensorData.value) ?? 0
        self.title = title ?? ""
    }
}
