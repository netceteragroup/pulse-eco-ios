//
//  CityOverallValues.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/10/20.
//

import Foundation

struct CityOverallValues: Codable {
    let cityName: String
    let values: [String: String]
    
    static var empty: CityOverallValues {
        CityOverallValues(cityName: "", values: [:])
    }
    
    static var dummy: CityOverallValues {
        CityOverallValues(cityName: "skopje", values: ["pm10": "10"])
    }
}
