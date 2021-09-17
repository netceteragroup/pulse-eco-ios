//
//  SensorPin.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/23/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
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
