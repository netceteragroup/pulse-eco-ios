//
//  Sensor.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/10/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import MapKit

struct Sensor: Codable  {
    var id: String { return sensorID }
    let sensorID: String
    let position: String
    let comments: String
    let type: String
    let description: String
    let status: String
  
    
    enum CodingKeys: String, CodingKey {
        case sensorID = "sensorId"
        case position, comments, type
        case description
        case status
    }
}

struct SensorData: Codable, Identifiable {
    let id = UUID()
    let sensorID: String
    let stamp: String
    let type: String
    let position: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case sensorID = "sensorId"
        case stamp, type, position, value
    }
    func getDate() -> Date {
        return DateFormatter.iso8601Full.date(from: self.stamp) ?? Date()
    }
}


