import Foundation
import MapKit

struct SensorModel: Codable  {
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

struct Sensor: Codable {
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
