//
//  MapVM.swift
//  PulseEco
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
    @ObservedObject var appDataSource: AppDataSource
    
    @Published private (set) var selectedCity: City! = UserSettings.selectedCity
    @Published private (set) var measure: Measure?
    @Published private (set) var sensors: [SensorPinModel]!
    var shouldUpdateSensors = false
    
    private (set) var span: MKCoordinateSpan!
    
    init(appState: AppState,
         appDataSource: AppDataSource) {
        self.appState = appState
        self.appDataSource = appDataSource
        self.span = span(for: selectedCity)
        observeStateChanges()
    }
    
    func getDailyAverageDataForSensor(_ sensorId: String) {
        appDataSource.getDailyAverageDataForSensor(city: selectedCity,
                                                   measure: measure,
                                                   sensorId: sensorId)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func observeStateChanges() {
        self.appState.$selectedCity.sink { [weak self] city in
            self?.setCity(city)
        }.store(in: &cancellables)
        self.appState.$selectedMeasure.sink { [weak self] selectedMeasureName in
            guard let sel = selectedMeasureName else { return }
            self?.findSelectedMeasure(sel)
        }.store(in: &cancellables)
        self.appDataSource.$measures.sink { [weak self] measures in
            self?.findSelectedMeasure(self?.measure?.id, measures: measures)
        }.store(in: &cancellables)
        self.appDataSource.$loadingCityData.sink { [unowned self] isLoading in
            guard !isLoading, let selectedMeasure = self.measure else { return }
            let sensors = combine(sensors: self.appDataSource.citySensors,
                                  sensorsData: self.appDataSource.sensorsData,
                                  selectedMeasure: selectedMeasure)
            guard !areIdentical(self.sensors, sensors) else { return }
            self.shouldUpdateSensors = true
            self.sensors = sensors
        }.store(in: &cancellables)
        self.appDataSource.$sensorsData.sink { [unowned self] data in
            guard let selectedMeasure = self.measure else { return }
            let sensors = combine(sensors: self.appDataSource.citySensors,
                                  sensorsData: data,
                                  selectedMeasure: selectedMeasure)
            guard !areIdentical(self.sensors, sensors) else { return }
            self.shouldUpdateSensors = true
            self.sensors = sensors
        }.store(in: &cancellables)
    }
    
    private func findSelectedMeasure(_ measure: String?, measures: [Measure]? = nil) {
        guard let measureName = measure else { return }
        let measures = measures ?? appDataSource.measures
        
        let selectedMeasure = measures.filter { $0.id.lowercased() == measureName.lowercased()}
            .first
        defer { self.measure = selectedMeasure }
        guard let measure = selectedMeasure else { return }
        let sensors = combine(sensors: appDataSource.citySensors,
                               sensorsData: appDataSource.sensorsData,
                              selectedMeasure: measure)
        guard !areIdentical(self.sensors, sensors) else { return }
        self.shouldUpdateSensors = true
        self.sensors = sensors
    }
    
    private func setCity(_ city: City) {
        guard city != self.selectedCity else {
            self.shouldUpdateSensors = true
            return
        }
        defer {
            self.selectedCity = city }
        self.span = span(for: city)
        self.shouldUpdateSensors = true
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
    
    private func pinColorForSensorValue(selectedMeasure: Measure, sensorValue: String) -> UIColor {
        return AppColors.colorFrom(string: selectedMeasure.bands.first { band in
            Int(sensorValue) ?? 0 >= band.from && Int(sensorValue) ?? 0 <= band.to
        }?.legendColor ?? "gray")
    }

    private func combine(sensors: [Sensor],
                         sensorsData: [SensorData],
                         selectedMeasure: Measure) -> [SensorPinModel] {
        var commonSensors = [SensorPinModel]()
        let sensorMeasurements = sensorsData.filter { sensor in
            sensor.type.lowercased() == selectedMeasure.id.lowercased()
        }
        _ = sensors.compactMap { sensor in
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

    private func areIdentical(_ lhs: [SensorPinModel]?, _ rhs: [SensorPinModel]?) -> Bool {
        guard let lhs = lhs, let rhs = rhs, lhs.count == rhs.count else { return false }
        for (index, value) in lhs.enumerated() {
            if !SensorPinModel.isIdentical(lhs: value, rhs: rhs[index]) { return false }
        }
        return true
    }
}
