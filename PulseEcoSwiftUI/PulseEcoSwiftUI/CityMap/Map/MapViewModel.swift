//
//  MapVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import MapKit
import Combine

class MapViewModel: ObservableObject {
    
    var cityName: String
    var coordinates: CLLocationCoordinate2D
    var intialZoomLevel: Int
    var cityBorderPoints: [CLLocationCoordinate2D] = []
    @Published var sensors = [SensorPinModel]()
    var measure: String
    
    init(measure: String,
         cityName: String,
         sensors: [Sensor],
         sensorsData: [SensorData],
         measures: [Measure],
         city: City) {
        let selectedMeasure = measures.filter{ $0.id.lowercased() == measure.lowercased()}
            .first ?? Measure.empty()
        self.cityName = cityName
        self.coordinates = CLLocationCoordinate2D(latitude: Double(city.cityLocation.latitude) ?? 0.0,
                                                  longitude: Double(city.cityLocation.longitute) ?? 0.0)
        self.cityBorderPoints = city.cityBorderPoints.compactMap {
            guard let lat = Double($0.latitude), let lon = Double($0.longitute) else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        self.intialZoomLevel = city.intialZoomLevel
        self.sensors = combine(sensors: sensors, sensorsData: sensorsData, selectedMeasure: measure).map {
            sensor in
            let coordinates = sensor.position.split(separator: ",")
            return SensorPinModel(title: sensor.description,
                            sensorID: sensor.sensorID,
                            value: sensor.value,
                            coordinate: CLLocationCoordinate2D(latitude: Double(coordinates[0]) ?? 0,
                                                               longitude: Double(coordinates[1]) ?? 0),
                            type: sensor.type,
                            color: pinColorForSensorValue(selectedMeasure: selectedMeasure,
                                                          sensorValue: sensor.value),
                            stamp: sensor.stamp
            )
        }
        self.measure = measure
    }
    
    func span() -> MKCoordinateSpan {
        let latitudes = self.cityBorderPoints.map { $0.latitude }
        let latDelta = abs((latitudes.max() ?? 0) - (latitudes.min() ?? 0))
        let longitudes = self.cityBorderPoints.map { $0.longitude }
        let lonDelta = abs((longitudes.max() ?? 0) - (longitudes.min() ?? 0))
        return MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
}

func pinColorForSensorValue(selectedMeasure: Measure, sensorValue: String) -> UIColor {
    return AppColors.colorFrom(string: selectedMeasure.bands.first{ band in
        Int(sensorValue) ?? 0 >= band.from && Int(sensorValue) ?? 0 <= band.to
        }?.legendColor ?? "gray")
}

func combine(sensors: [Sensor], sensorsData: [SensorData], selectedMeasure: String) -> [SensorPin] {
    var commonSensors = [SensorPin]()
    let selectedMeasureSensors = sensorsData.filter { sensor in
        sensor.type.lowercased() == selectedMeasure.lowercased()
    }
    let _ = sensors.compactMap{ sensor in
        selectedMeasureSensors.compactMap{ selectedMeasureSensor in
            if selectedMeasureSensor.sensorID == sensor.sensorID {
                commonSensors.append(SensorPin(sensorID: sensor.sensorID,
                                               stamp: selectedMeasureSensor.stamp,
                                               type: sensor.type,
                                               position: sensor.position,
                                               value: selectedMeasureSensor.value,
                                               description: sensor.description))
            }
        }
    }
    return commonSensors
}
