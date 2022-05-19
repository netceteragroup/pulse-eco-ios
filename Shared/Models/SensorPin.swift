//
//  SensorPin.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/23/21.
//

import Foundation

struct SensorPin: Identifiable {
    let id = UUID()
    let sensorID: String
    let stamp: String
    let type: String
    let position: String
    let value: String
    let description: String
}
