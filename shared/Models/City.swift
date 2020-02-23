import Foundation
import CoreLocation
import PromiseKit

struct City {
    let name: String
    let key: String
    let siteUrl: URL
    let countryCode: String
    let countryName: String
    let initialZoomLevel: Float
    let coordinates: Coordinate
    let cityBorderPoints: [Coordinate]
    var basedOnLocation: Bool = false

    var currentSensorReadings: [SensorReading]
    var sensorReadings: [SensorReading]
    var sensors: [Sensor]

    init(name: String,
         key: String,
         siteUrl: URL,
         countryCode: String,
         countryName: String,
         initialZoomLevel: Float,
         coordinates: Coordinate,
         cityBorderPoints: [Coordinate],
         currentSensorReadings: [SensorReading],
         sensorReadings: [SensorReading],
         sensors: [Sensor]) {
        self.name = name
        self.key = key
        self.siteUrl = siteUrl
        self.countryCode = countryCode
        self.countryName = countryName
        self.initialZoomLevel = initialZoomLevel
        self.coordinates = coordinates
        self.cityBorderPoints = cityBorderPoints
        self.currentSensorReadings = currentSensorReadings
        self.sensorReadings = sensorReadings
        self.sensors = sensors
    }
    
    // if cities are not loaded, this is the default city
    static func defaultCity() -> City {
//        "cityName": "skopje",
//        "siteName": "Skopje",
//        "siteTitle": "Skopje @ CityPulse",
//        "siteUrl": "https://skopje.pulse.eco",
//        "countryCode": "MK",
//        "countryName": "Macedonia",
//        "cityLocation": {
//        "latitude": "42.0016",
//        "longitute": "21.4302"
//        },
//        "cityBorderPoints": [],
//        "intialZoomLevel": 12
        
        /*
         "cityName": "skopje",
           "siteName": "Skopje",
           "siteTitle": "Skopje @ CityPulse",
           "siteUrl": "https://skopje.pulse.eco",
           "countryCode": "MK",
           "countryName": "Macedonia",
           "cityLocation": {
             "latitude": "42.0016",
             "longitute": "21.4302"
           },
         */
        
        let cityBorderPoints = [Coordinate(latitude: 42.04602, longitude: 21.4383023),
                                Coordinate(latitude: 42.055145, longitude: 21.376596),
                                Coordinate(latitude: 42.052561,longitude: 21.3379023),
                                Coordinate(latitude: 42.009616,longitude: 21.324233),
                                Coordinate(latitude: 41.981676,longitude: 21.340713),
                                Coordinate(latitude: 41.959213,longitude: 21.395816),
                                Coordinate(latitude: 41.937931,longitude: 21.422112),
                                Coordinate(latitude: 41.946064,longitude: 21.456927),
                                Coordinate(latitude: 41.905275,longitude: 21.518029),
                                Coordinate(latitude: 41.977848,longitude: 21.721801),
                                Coordinate(latitude: 42.046977,longitude: 21.659659),
                                Coordinate(latitude: 42.032188,longitude: 21.491431),
                                Coordinate(latitude: 42.023772,longitude: 21.555633),
                                Coordinate(latitude: 41.928439,longitude: 21.3648833),
                                Coordinate(latitude: 41.88039992692813,longitude: 21.59568786621094),
                                Coordinate(latitude: 41.914643492538715,longitude: 21.665725708007816),
                                Coordinate(latitude: 41.93993104859892,longitude: 21.695251464843754)]
        
        return City(name: "Skopje",
                    key: "skopje",
                    siteUrl: URL(string: "https://skopje.pulse.eco")!,
                    countryCode: "MK",
                    countryName: "Macedonia",
                    initialZoomLevel: 12.0,
                    coordinates: Coordinate(latitude: 42.0016, longitude: 21.4302),
                    cityBorderPoints: cityBorderPoints,
                    currentSensorReadings: [],
                    sensorReadings: [],
                    sensors: [])
    }

//    func updateSensorsAndReadings() -> Promise<([Sensor], [Reading])> {
//		let sensorsUrl = siteUrl.appendingPathComponent("rest").appendingPathComponent("sensor")
//        let data24hUrl = siteUrl.appendingPathComponent("rest").appendingPathComponent("data24h")
//        let sensorsPromise = DataSource.shared.getDataFromAPI(baseUrl: sensorsUrl)
//		let readingsPromise = DataSource.shared.getDataFromAPI(baseUrl: data24hUrl)
//
//		return when(fulfilled: [sensorsPromise, readingsPromise])
//			.then { response -> Promise<([Sensor], [Reading])> in
//				self.sensors = try JSONDecoder().decode([Sensor].self, from: response[0])
//				self.readings = try JSONDecoder().decode([Reading].self, from: response[1])
//				return Promise.value((self.sensors, self.readings))
//			}
//    }

//    func getAllSensorReadings() -> [SensorReading] {
//        #warning("This should use the current readings")
//        return []
//        var sensorReadings: [SensorReading] = []
//
//        for sensor in sensors {
//            for reading in readings where sensor.id == reading.sensorId {
//                sensorReadings.append(SensorReading(sensor: sensor, reading: reading))
//            }
//        }
//
//        return sensorReadings
//    }

    func getLatestSensorReadings(forMeasureId measureId: String) -> [SensorReading] {
        return sensorReadings.filter { reading in
            reading.type == measureId
        }
    }

    func getReadingsForSensor(sensorId id: String, forMeasureId measureId: String) -> [SensorReading] {
        let filteredReadings = getLatestSensorReadings(forMeasureId: measureId).filter { reading in
            reading.sensorId == id
        }

        return filteredReadings
    }

    func getLatestReadingsForSensor(sensorId id: String) -> [SensorReading] {
        #warning("Probably not needed")
//        let filteredReadings = getAllSensorReadings().filter { reading in
//            reading.sensorId == id && reading.stamp.timeIntervalSinceNow > -twoHourInterval
//        }
//
//        return filteredReadings
        return []
    }

    func bounds() -> Bounds {
        let northEastBound = getNorthEastBound()
        let southWestBound = getSouthWestBound()

        return Bounds(NEBound: northEastBound, SWBound: southWestBound)
    }

    private func getNorthEastBound() -> Coordinate { // max - max

        var maxLng = cityBorderPoints[0].longitude
        var maxLat = cityBorderPoints[0].latitude
        self.cityBorderPoints.forEach {
            if $0.longitude > maxLng {
                maxLng = $0.longitude
            }
            if $0.latitude > maxLat {
                maxLat = $0.latitude
            }
        }

        return Coordinate(latitude: maxLat, longitude: maxLng)
    }

    private func getSouthWestBound() -> Coordinate { // min - min

        var minLng = self.cityBorderPoints[0].longitude
        var minLat = self.cityBorderPoints[0].latitude
        self.cityBorderPoints.forEach {
            if $0.longitude < minLng {
                minLng = $0.longitude
            }
            if $0.latitude < minLat {
                minLat = $0.latitude
            }
        }

        return Coordinate(latitude: minLat, longitude: minLng)
    }

    func average(forMeasureId measureId: String) -> Double {
        var sum = 0.0
        var count = 0

        getLatestSensorReadings(forMeasureId: measureId).forEach { sensorReading in
            #warning("Make sure this won't fail")
            sum += Double(sensorReading.value)!
            count += 1
        }

        return sum / Double(count)
    }
}

extension City: Codable {
//    "cityName": "novoselo",
//    "siteName": "Novo Selo",
//    "siteTitle": "Novo Selo @ pulse.eco",
//    "siteUrl": "https://novoselo.pulse.eco",
//    "cityLocation": {
//        "latitude": "41.413349",
//        "longitute": "22.880672"
//    },
//    "cityBorderPoints": [
//        {
//        "latitude": "41.420901",
//        "longitute": "22.863232"
//        },
//        {
//        "latitude": "41.425250",
//        "longitute": "22.880324"
//        },
//        {
//        "latitude": "41.420049",
//        "longitute": "22.899684"
//        }
//    ],
//    "intialZoomLevel": 15

//    re-map the keys from the API to our model

    private enum CityCodingKeys: String, CodingKey {
        case name = "siteName" // human readable name
        case key = "cityName" // unique id used by the data source
        case siteUrl
        case countryCode
        case countryName
        case initialZoomLevel = "intialZoomLevel" // typo from the API
        case cityLocation
        case cityBorderPoints
        case sensors
        case currentSensorReadings
        case sensorReadings
    }
    
    init(from decoder: Decoder) throws {
        let cityContainer = try decoder.container(keyedBy: CityCodingKeys.self)
        name = try cityContainer.decode(String.self, forKey: .name)
        key = try cityContainer.decode(String.self, forKey: .key)
        siteUrl = try cityContainer.decode(URL.self, forKey: .siteUrl)
        initialZoomLevel = try cityContainer.decode(Float.self, forKey: .initialZoomLevel)
        countryCode = try cityContainer.decode(String.self, forKey: .countryCode)
        countryName = try cityContainer.decode(String.self, forKey: .countryName)
        coordinates = try cityContainer.decode(Coordinate.self, forKey: .cityLocation)
        cityBorderPoints = try cityContainer.decode([Coordinate].self, forKey: .cityBorderPoints)
        sensors = (try? cityContainer.decode([Sensor].self, forKey: .sensors)) ?? []
        currentSensorReadings = (try? cityContainer.decode([SensorReading].self, forKey: .currentSensorReadings)) ?? []
        sensorReadings = (try? cityContainer.decode([SensorReading].self, forKey: .sensorReadings)) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var cityContainer = encoder.container(keyedBy: CityCodingKeys.self)
        try cityContainer.encode(name, forKey: .name)
        try cityContainer.encode(key, forKey: .key)
        try cityContainer.encode(siteUrl, forKey: .siteUrl)
        try cityContainer.encode(initialZoomLevel, forKey: .initialZoomLevel)
        try cityContainer.encode(countryCode, forKey: .countryCode)
        try cityContainer.encode(countryName, forKey: .countryName)
        try cityContainer.encode(coordinates, forKey: .cityLocation)
        try cityContainer.encode(cityBorderPoints, forKey: .cityBorderPoints)
        try cityContainer.encode(sensors, forKey: .sensors)
        try cityContainer.encode([SensorReading](), forKey: .currentSensorReadings)
        try cityContainer.encode([SensorReading](), forKey: .sensorReadings)
    }
}
