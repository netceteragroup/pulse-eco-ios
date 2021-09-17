import Foundation

class ChartViewModel: ObservableObject {
    @Published var sensor: SensorPinModel
    @Published var sensorsData24h: [SensorData]
    @Published var selectedMeasure: Measure
    @Published var sensorReadings: [SensorData]
    
     init(sensor: SensorPinModel, sensorsData: [SensorData], selectedMeasure: Measure) {
        self.sensor = sensor
        self.sensorsData24h = sensorsData
        self.selectedMeasure = selectedMeasure

        self.sensorReadings = sensorsData.filter{
            $0.sensorID == sensor.sensorID && $0.type == selectedMeasure.id
        }.sorted{ (s1, s2) in
            let date = DateFormatter.iso8601Full.date(from: s1.stamp) ?? Date()
            let date1 = DateFormatter.iso8601Full.date(from: s2.stamp) ?? Date()
            return date < date1
        }
    }
    
}
