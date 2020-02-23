import Foundation

struct SensorReading: Equatable {
    let sensorId: String
    let stamp: Date
    let type: String
    let position: Coordinate
    var description: String = ""
    let value: String
    
    init(sensor: Sensor, reading: Reading) {
        sensorId = sensor.id
        position = sensor.coordinates
        type = reading.type
        description = sensor.description
        stamp = reading.stamp
        value = String(reading.value)
    }
}

extension SensorReading: Codable {
    
    //  "sensorId": "1005",
    //  "stamp": "2019-10-18T21:00:28Z",
    //  "type": "no2",
    //  "position": "41.9992,21.4408",
    //  "value": "88"
    
    private enum SensorReadingCodingKeys: String, CodingKey {
        case sensorId
        case stamp
        case type
        case position
        case value
    }
    
    init(from decoder: Decoder) throws {
        let readingContainer = try decoder.container(keyedBy: SensorReadingCodingKeys.self)
        
        sensorId = try readingContainer.decode(String.self, forKey: .sensorId)
        let dateString = try readingContainer.decode(String.self, forKey: .stamp)
        
        guard let date = DateFormatter.iso8601Full.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .stamp,
                                                   in: readingContainer,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        stamp = date
            
        type = try readingContainer.decode(String.self, forKey: .type)
        
        let positionString = try readingContainer.decode(String.self, forKey: .position)
        let positionComponents = positionString.split(separator: ",")
        let trimmedCoordinates = positionComponents.map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard let latitude = Double(trimmedCoordinates[0]),
              let longitude = Double(trimmedCoordinates[1]) else {
                throw DecodingError.dataCorruptedError(forKey: .position,
                                                       in: readingContainer,
                                                       debugDescription: "Can not convert String value into Double.")
        }
        position = Coordinate(latitude: latitude, longitude: longitude)
        
        value = try readingContainer.decode(String.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: SensorReadingCodingKeys.self)
        try container.encode(sensorId, forKey: .sensorId)
        var dateString = DateFormatter.iso8601Full.string(from: stamp)
        try container.encode(dateString, forKey: .stamp)
        try container.encode(type, forKey: .type)
        let positionString = String(position.latitude) + "," + String(position.longitude)
        try container.encode(positionString, forKey: .position)
        try container.encode(value, forKey: .value)
    }
}
