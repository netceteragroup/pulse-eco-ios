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
import SwiftUI

class MapViewModel: ObservableObject {
    
    let appState: AppState
    let appDataSource: AppDataSource
    
    @Published private (set) var selectedCity: City = City.defaultCity()
    @Published private (set) var measure: Measure!
    @Published private (set) var sensors: [SensorPinModel]!
    
    private (set) var span: MKCoordinateSpan!
    
    private var cancellables = Set<AnyCancellable>()
    
    private func observeStateChanges() {
        self.appState.$cityName.sink { [weak self] cityName in
            self?.findSelectedCity(name: cityName)
        }.store(in: &cancellables)
        self.appState.$selectedMeasure.sink { [weak self] selectedMeasureName in
            self?.findSelectedMeasure(selectedMeasureName)
        }.store(in: &cancellables)
        
    }
    
    private func findSelectedMeasure(_ measure: String) {
        let selectedMeasure = appDataSource.measures.filter{ $0.id.lowercased() == measure.lowercased()}
            .first ?? Measure.empty()
        defer { self.measure = selectedMeasure }
        let sensors = combine(sensors: appDataSource.citySensors,
                               sensorsData: appDataSource.sensorsData,
                              selectedMeasure: selectedMeasure)
        self.sensors = sensors
    }
    
    private func findSelectedCity(name: String) {
        guard let city =
                (appDataSource.cities.first {
                    $0.cityName == name
                })
        else {
            self.span = span(for: City.defaultCity())
            return }
        defer { self.selectedCity = city }
        self.span = span(for: city)
    }

    init(appState: AppState,
        appDataSource: AppDataSource) {
        self.appState = appState
        self.appDataSource = appDataSource
        observeStateChanges()
    }
    
    private func span(for city: City) -> MKCoordinateSpan {
        let borders: [CLLocationCoordinate2D] = city.cityBorderPoints.compactMap {
            guard let lat = Double($0.latitude), let lon = Double($0.longitute) else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        let latitudes = borders.map { $0.latitude }
        let latDelta = abs((latitudes.max() ?? 0) - (latitudes.min() ?? 0))
        let longitudes = borders.map { $0.longitude }
        let lonDelta = abs((longitudes.max() ?? 0) - (longitudes.min() ?? 0))
        return MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
}

func pinColorForSensorValue(selectedMeasure: Measure, sensorValue: String) -> UIColor {
    return AppColors.colorFrom(string: selectedMeasure.bands.first{ band in
        Int(sensorValue) ?? 0 >= band.from && Int(sensorValue) ?? 0 <= band.to
    }?.legendColor ?? "gray")
}

func combine(sensors: [Sensor],
             sensorsData: [SensorData],
             selectedMeasure: Measure) -> [SensorPinModel] {
    var commonSensors = [SensorPinModel]()
    let sensorMeasurements = sensorsData.filter { sensor in
        sensor.type.lowercased() == selectedMeasure.id.lowercased()
    }
    let _ = sensors.compactMap{ sensor in
        sensorMeasurements.compactMap { sensorMeasurement in
            if sensorMeasurement.sensorID == sensor.sensorID {
                commonSensors.append(
                    SensorPinModel(title: sensor.description,
                                   sensorID: sensor.sensorID, value: sensorMeasurement.value,
                                   position: sensor.position,
                                   type: sensor.type,
                                   color: pinColorForSensorValue(selectedMeasure: selectedMeasure,
                                   sensorValue: sensorMeasurement.value),
                                   stamp: sensorMeasurement.stamp)
                
                )
            }
        }
    }
    return commonSensors
}
