import Foundation

struct OverallValues: Codable {
    let cityName: String
    var values: [String: String]
}

//{
//    "cityName": "skopje",
//    "values": {
//        "no2": "13",
//        "pm25": "19",
//        "o3": "79",
//        "so2": "5",
//        "pm10": "26",
//        "noise": "65",
//        "temperature": "26",
//        "humidity": "45",
//        "pressure": "964",
//        "co": "0",
//        "gasResistance": "499492"
//    }
//}
