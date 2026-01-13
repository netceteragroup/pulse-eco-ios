//
//  DailyInfoSensor.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/22/21.
//

import Foundation

struct DailyInfoSensor: Identifiable {
    var id: String {
        dayOfWeek
    }
    var dayOfWeek: String
    var value: String
}
