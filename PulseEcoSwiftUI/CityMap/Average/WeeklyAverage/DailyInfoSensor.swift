//
//  DailyInfoSensor.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/22/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation

struct DailyInfoSensor: Identifiable {
    var id = UUID()
    var dayOfWeek: String
    var value: String
}
