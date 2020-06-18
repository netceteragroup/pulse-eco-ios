import Foundation
import CoreLocation

struct Sensor {
    let id: String
    let coordinates: Coordinate
    let comments: String
    let type: SensorType
    let description: String
    let status: SensorStatus
   
}

extension Sensor: Codable {
//    "sensorId": "11888f3a-bc5e-4a0c-9f27-702984decedf",
//    "position": "41.995828195848325,21.484215259552002",
//    "comments": "V1 wifi sensor in MZT area",
//    "type": "2",
//    "description": "MZT",
//    "status": "ACTIVE"

    private enum SensorCodingKeys: String, CodingKey {
        case id = "sensorId"
        case coordinates = "position"
        case comments
        case type
        case description
        case status
    }

    init(from decoder: Decoder) throws {
        let sensorContainer = try decoder.container(keyedBy: SensorCodingKeys.self)
        id = try sensorContainer.decode(String.self, forKey: .id)
        comments = try sensorContainer.decode(String.self, forKey: .comments)
        do { type = try sensorContainer.decode(SensorType.self, forKey: .type)
        } catch {
            type = .undefined
        }
        description = try sensorContainer.decode(String.self, forKey: .description)
        status = (try? sensorContainer.decode(SensorStatus.self, forKey: .status)) ?? .unknown

        let coordinatesString = try sensorContainer.decode(String.self, forKey: .coordinates)
        let coordinatesComponents = coordinatesString.split(separator: ",")
        let trimmedCoordinates = coordinatesComponents.map { $0.trimmingCharacters(in: .whitespaces) }

        guard let latitude = Double(trimmedCoordinates[0]),
              let longitude = Double(trimmedCoordinates[1]) else {
                throw DecodingError.dataCorruptedError(forKey: .coordinates,
                                                   in: sensorContainer,
                                                   debugDescription: "Can not convert String value into Double.")
        }
        coordinates = Coordinate(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SensorCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(comments, forKey: .comments)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(status, forKey: .status)
        
        let positionString = String(coordinates.latitude) + "," + String(coordinates.longitude)
        try container.encode(positionString, forKey: .coordinates)
    }
}
