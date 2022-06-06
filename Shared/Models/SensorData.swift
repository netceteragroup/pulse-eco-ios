//
//  Sensor.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/10/20.
//

import Foundation
import MapKit

struct Sensor: Codable {
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
    let position: String?
    let value: String

    enum CodingKeys: String, CodingKey {
        case sensorID = "sensorId"
        case stamp, type, position, value
    }
    func getDate() -> Date? {
        return DateFormatter.iso8601Full.date(from: self.stamp)
    }
}

/// Extension that allows average data to be found from an array of SensorDataElements
extension Array where Element == SensorData {
    func averageValue () -> Int {
        var count = 0
        var increment = 0
        for element in self where Int(element.value) != nil {
            count += Int(element.value)!
            increment += 1
        }
        if increment == 0 { increment = 1 }
        
        return count / increment
    }
}
