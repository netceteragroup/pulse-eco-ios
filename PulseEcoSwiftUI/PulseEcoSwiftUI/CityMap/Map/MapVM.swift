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

class MapVM: ObservableObject {
    
    var cityName: String
    var coordinates: CLLocationCoordinate2D
    var intialZoomLevel: Int
    var cityBorderPoints: [CLLocationCoordinate2D] = []
    var sensors = [SensorVM]()
    var measure: String
    
    init(measure: String, cityName: String, sensors: [SensorModel], sensorsData: [Sensor], measures: [Measure], city: CityModel) {
        let selectedMeasure = measures.filter{ $0.id.lowercased() == measure.lowercased()}.first ?? Measure.empty()
        self.cityName = cityName
        self.coordinates = CLLocationCoordinate2D(latitude: Double(city.cityLocation.latitude) ?? 0.0, longitude: Double(city.cityLocation.longitute) ?? 0.0)
        for border in city.cityBorderPoints {
            self.cityBorderPoints.append(CLLocationCoordinate2D(latitude: Double(border.latitude) ?? 0.0, longitude:  Double(border.longitute) ?? 0.0))
        }
        self.intialZoomLevel = city.intialZoomLevel
        self.sensors = combine(sensors: sensors, sensorsData: sensorsData, selectedMeasure: measure).map {
            sensor in
            let coordinates = sensor.position.split(separator: ",")
            return SensorVM(title: sensor.description,
                            sensorID: sensor.sensorID,
                            value: sensor.value,
                            coordinate: CLLocationCoordinate2D(latitude: Double(coordinates[0]) ?? 0, longitude: Double(coordinates[1]) ?? 0),
                            type: sensor.type,
                            color:  AppColors.colorFrom(string: selectedMeasure.bands.first{ band in
                                Int(sensor.value) ?? 0 >= band.from && Int(sensor.value) ?? 0 <= band.to
                                }?.legendColor ?? "gray"),
                            stamp: sensor.stamp
            )
        }
        self.measure = measure
    }
    
}

func combine(sensors: [SensorModel], sensorsData: [Sensor], selectedMeasure: String) -> [SensorPin] {
    var commonSensors = [SensorPin]()
    let selectedMeasureSensors = sensorsData.filter { sensor in
        sensor.type.lowercased() == selectedMeasure.lowercased()
    }
    
    let _ = sensors.filter { sensor in
        selectedMeasureSensors.contains{ selectedMeasureSensor in
            if (selectedMeasureSensor.sensorID == sensor.sensorID) {
                commonSensors.append(SensorPin(sensorID: sensor.sensorID,
                                               stamp: selectedMeasureSensor .stamp,
                                               type: sensor.type,
                                               position: sensor.position,
                                               value: selectedMeasureSensor.value,
                                               description: sensor.description))
            }
            return false
        }
    }
    return commonSensors
}

struct SensorPin: Codable, Identifiable {
    let id = UUID()
    let sensorID: String
    let stamp: String
    let type: String
    let position: String
    let value: String
    let description: String
}
