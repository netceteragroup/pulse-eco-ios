//
//  SensorDetailsVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/19/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class SensorDetailsVM {
    var sensorID: String
    var sensorType: SensorType
    var title: String
    var value: String
    var unit: String
    var time: String
    var date: String
    var image: UIImage
    init(sensor: SensorVM, sensorsData: [Sensor], selectedMeasure: Measure) {
        self.sensorID = sensor.sensorID
        self.sensorType = sensor.type
        self.title = sensor.title ?? "Sensor"
        self.value = sensor.value
        self.unit = selectedMeasure.unit
        let date = DateFormatter.iso8601Full.date(from: sensor.stamp) ?? Date()
        self.date = DateFormatter.getDate.string(from: date)
        self.time = DateFormatter.getTime.string(from: date)
        self.image = sensorType.imageForType ?? UIImage()
    }
}
