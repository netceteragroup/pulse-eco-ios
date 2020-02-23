import Foundation
import CoreLocation

/// Reading model that is being delivered from the API.
/// It parses the data automatically.
struct Reading {
    let sensorId: String
    let stamp: Date
    let type: String
    let coordinates: Coordinate
    let value: Double
}

extension Reading: Codable {

//    "sensorId": "7c497bfd-36b6-4eed-9172-37fd70f17c48",
//    "stamp": "2019-03-16T00:35:46+01:00",
//    "type": "pm10",
//    "position": "42.01313055226713,21.45875573158264",
//    "value": "19"

    private enum ReadingCodingKeys: String, CodingKey {
        case sensorId
        case stamp
        case type
        case coordinates = "position"
        case value
    }

    init(from decoder: Decoder) throws {
        let readingContainer = try decoder.container(keyedBy: ReadingCodingKeys.self)

        sensorId = try readingContainer.decode(String.self, forKey: .sensorId)
        type = try readingContainer.decode(String.self, forKey: .type)

        // position
        let coordinatesString = try readingContainer.decode(String.self, forKey: .coordinates)
        let coordinatesComponents = coordinatesString.split(separator: ",")
        let trimmedCoordinates = coordinatesComponents.map { $0.trimmingCharacters(in: .whitespaces) }

        guard let latitude = Double(trimmedCoordinates[0]),
              let longitude = Double(trimmedCoordinates[1]) else {
                throw DecodingError.dataCorruptedError(forKey: .coordinates,
                                                       in: readingContainer,
                                                       debugDescription: "Can not convert String value into Double.")
        }
        coordinates = Coordinate(latitude: latitude, longitude: longitude)

        // value
        let valueString = try readingContainer.decode(String.self, forKey: .value)
        guard let doubleValue = Double(valueString) else {
            throw DecodingError.dataCorruptedError(forKey: .value,
                                                   in: readingContainer,
                                                   debugDescription: "Can not convert string value into Double.")
        }
        value = doubleValue

        // stamp
        let dateString = try readingContainer.decode(String.self, forKey: .stamp)
        guard let date = DateFormatter.iso8601Full.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .stamp,
                                                   in: readingContainer,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        stamp = date
    }
}
