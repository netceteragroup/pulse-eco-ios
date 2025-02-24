//
//  SensorSelectionViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 27.1.25.
//

import Foundation

@MainActor
class SensorSelectionViewModel: ObservableObject {
    @Published var selectedSensors: [SensorPinModel] = []
    @Published var tmpSelectedSensors: [SensorPinModel] = []
    var sensors: [SensorPinModel] = []
    var appState: AppState
    
    init(appState: AppState, sensors: [SensorPinModel]) {
        self.appState = appState
        self.sensors = sensors
        self.tmpSelectedSensors = appState.selectedSensorsForGraph
    }
    
    func toggleSelection(for sensor: SensorPinModel) {
        if let index = tmpSelectedSensors.firstIndex(where: { $0.sensorID == sensor.sensorID }) {
            tmpSelectedSensors.remove(at: index)
        } else {
            tmpSelectedSensors.append(sensor)
        }
    }
    
    func cancel(sensorSelectionAlertDialogIsActive: inout Bool) {
        tmpSelectedSensors = selectedSensors
        sensorSelectionAlertDialogIsActive = false
    }
    
    func addToSelectedSensors(sensorSelectionAlertDialogIsActive: inout Bool) {
        selectedSensors = tmpSelectedSensors
        sensorSelectionAlertDialogIsActive = false
        appState.selectedSensorsForGraph = selectedSensors
    }
    
    func isDisabled(sensor: SensorPinModel) -> Bool {
        self.tmpSelectedSensors.count == 5 && !self.tmpSelectedSensors.contains(where: {$0.sensorID == sensor.sensorID})
    }
}
