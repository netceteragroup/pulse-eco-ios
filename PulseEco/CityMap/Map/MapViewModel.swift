//
//  MapVM.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import Foundation
import MapKit
import Combine
import SwiftUI
import Factory

class MapViewModel: ObservableObject {
    
    @Injected(\.appData) private var appData
    @Injected(\.appDataManager) private var appDataManager
    
    @Published private(set) var sensors: [SensorPinModel] = []
    var shouldUpdateSensors = false
    
    private(set) var span: MKCoordinateSpan!
    
    init() {
        self.span = span(for: UserSettings.selectedCity)
        observeStateChanges()
    }
    
    func onFloatingButtonTap() {
        appData.isTimelineSliderActive = true
    }
    
    func onSliderChanged(value: Double) {
        guard let sensorPinsForSelectedHour = appData.hourlySensors[Int(value)] else {
            appData.sensorPins = [SensorPinModel()]
            return
        }
        
        if sensorPinsForSelectedHour.isEmpty || sensorPinsForSelectedHour == appData.sensorPins {
            return
        }
        
        appData.sensorPins = sensorPinsForSelectedHour
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func observeStateChanges() {
        self.appDataManager.onSensorPinsUpdated.sink { [weak self] sensorPins in
            self?.sensors = sensorPins
            self?.shouldUpdateSensors = true
        }.store(in: &cancellables)
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
