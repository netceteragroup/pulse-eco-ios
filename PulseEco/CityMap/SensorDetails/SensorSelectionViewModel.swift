//
//  SensorSelectionViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 27.1.25.
//

import Foundation
import Factory

@MainActor
class SensorSelectionViewModel: ObservableObject {
    @Published var selectedSensors: [SensorPinModel] = []
    @Published var tmpSelectedSensors: [SensorPinModel] = []
    var sensors: [SensorPinModel] = []
    @Injected(\.appData) private var appData: AppDataProtocol

    init(sensors: [SensorPinModel]) {
        self.sensors = sensors
        self.tmpSelectedSensors = appData.selectedSensorsForGraph
    }
    
    var filteredSensors: [SensorPinModel] {
        sensors.filter { $0.measureId == appData.selectedMeasureId }
    }
    
    func toggleSelection(for sensor: SensorPinModel) {
        if let index = tmpSelectedSensors.firstIndex(where: { $0.sensorID == sensor.sensorID }) {
            tmpSelectedSensors.remove(at: index)
        } else {
            tmpSelectedSensors.append(sensor)
        }
    }
    
    func setShowSensorDetails(_ showDetails: Bool) {
        appData.showSensorDetails = showDetails
    }
        
    func cancel(sensorSelectionAlertDialogIsActive: inout Bool) {
        tmpSelectedSensors = selectedSensors
        sensorSelectionAlertDialogIsActive = false
    }
    
    func addToSelectedSensors(sensorSelectionAlertDialogIsActive: inout Bool) {
        selectedSensors = tmpSelectedSensors
        sensorSelectionAlertDialogIsActive = false
        appData.selectedSensorsForGraph = selectedSensors
    }
    
    func isDisabled(sensor: SensorPinModel) -> Bool {
        self.tmpSelectedSensors.count == 5 && !self.tmpSelectedSensors.contains(where: {$0.sensorID == sensor.sensorID})
    }
}
