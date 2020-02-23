import CoreLocation

struct Coordinate {
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
}

extension Coordinate: Codable, Equatable {
    private enum CoordinateCodingKeys: String, CodingKey {
        case latitude
        case longitude = "longitute" // typo from the API
    }

    init(from decoder: Decoder) throws {
        let coordinateContainer = try decoder.container(keyedBy: CoordinateCodingKeys.self)

        let latitudeString = try coordinateContainer.decode(String.self, forKey: .latitude)
        guard let latitude = CLLocationDegrees(latitudeString) else {
            throw DecodingError.dataCorruptedError(forKey: .latitude,
                                                   in: coordinateContainer,
                                                   debugDescription: "Can not convert String value into CLLocationDegrees.")
        }

        let longitudeString = try coordinateContainer.decode(String.self, forKey: .longitude)
        guard let longitude = CLLocationDegrees(longitudeString) else {
            throw DecodingError.dataCorruptedError(forKey: .longitude,
                                                   in: coordinateContainer,
                                                   debugDescription: "Can not convert String value into CLLocationDegrees.")
        }

        self.latitude = latitude
        self.longitude = longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var coordinateContainer = encoder.container(keyedBy: CoordinateCodingKeys.self)
        try coordinateContainer.encode(String(self.latitude), forKey: .latitude)
        try coordinateContainer.encode(String(self.longitude), forKey: .longitude)
    }
}
