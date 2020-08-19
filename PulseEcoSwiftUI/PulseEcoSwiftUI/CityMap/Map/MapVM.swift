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
            let coordinates = sensor.sensorModel.position.split(separator: ",")
            return SensorVM(title: sensor.sensorModel.description,
                            sensorID: sensor.sensorData.sensorID,
                            value: sensor.sensorData.value,
                            coordinate: CLLocationCoordinate2D(latitude: Double(coordinates[0]) ?? 0, longitude: Double(coordinates[1]) ?? 0),
                            type: sensor.sensorModel.type,
                            color:  AppColors.colorFrom(string: selectedMeasure.bands.first{ band in
                                Int(sensor.sensorData.value) ?? 0 >= band.from && Int(sensor.sensorData.value) ?? 0 <= band.to
                                }?.legendColor ?? "gray"),
                            stamp: sensor.sensorData.stamp
            )
        }
        self.measure = measure
    }
    
}

class SensorReadings {
    var sensorModel: SensorModel
    var sensorData: Sensor
    init(sensorModel: SensorModel, sensorData: Sensor) {
        self.sensorModel = sensorModel
        self.sensorData = sensorData
    }
}

func combine(sensors: [SensorModel], sensorsData: [Sensor], selectedMeasure: String) -> [SensorReadings] {

    let sensorDataIds = sensorsData.filter { sensor in
        sensor.type.lowercased() == selectedMeasure.lowercased()
    }

    let commonSensors = sensors.filter { sensor in
        sensorDataIds.contains{
        data in
        data.sensorID == sensor.id
        }
    }
    return zip(commonSensors, sensorDataIds).map { SensorReadings(sensorModel: $0, sensorData: $1) }
}
