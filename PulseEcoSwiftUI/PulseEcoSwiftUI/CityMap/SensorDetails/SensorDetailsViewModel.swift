//
//  SensorDetailsVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/19/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class SensorDetailsViewModel: ObservableObject {
    var sensorID: String
    var sensorType: SensorType
    var title: String
    var value: String
    var unit: String
    var time: String
    var date: String
    var image: UIImage
    var disclaimerMessage = Trema.text(for: "disclaimer_short_message")
    var color = Color(AppColors.darkblue)
    @Published var sensorData24h: [SensorData]
    @Published var dailyAverages: [SensorData]

    init(sensor: SensorVM, sensorsData: [SensorData], selectedMeasure: Measure, sensorData24h: [SensorData], dailyAverages: [SensorData]) {
        self.sensorID = sensor.sensorID
        self.sensorType = sensor.type
        self.title = sensor.title ?? "Sensor"
        self.value = sensor.value
        self.unit = selectedMeasure.unit
        let date = DateFormatter.iso8601Full.date(from: sensor.stamp) ?? Date()
        self.date = DateFormatter.getDate.string(from: date)
        self.time = DateFormatter.getTime.string(from: date)
        self.image = sensorType.imageForType ?? UIImage()
        self.sensorData24h = sensorData24h
        self.dailyAverages = dailyAverages
    }
}
