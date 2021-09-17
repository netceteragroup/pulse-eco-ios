//
//  City1.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/10/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation

struct City: Codable, Identifiable, Hashable {
   
    var id: String { return cityName }
    let cityName, siteName, siteTitle: String
    let siteURL: String
    let countryCode: String
    let countryName: String
    let cityLocation: CityCoordinates
    let cityBorderPoints: [CityCoordinates]
    let intialZoomLevel: Int

    enum CodingKeys: String, CodingKey {
        case cityName, siteName, siteTitle
        case siteURL = "siteUrl"
        case countryCode, countryName, cityLocation, cityBorderPoints, intialZoomLevel
    }
    static func == (lhs: City, rhs: City) -> Bool {
            lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    init(cityName: String = "skopje",
         siteName: String = "Skopje",
         siteTitle: String = "Skopje @ CityPulse",
         siteURL: String = "https://skopje.pulse.eco",
         countryCode: String = "MK",
         countryName: String = "Macedonia",
        cityLocation: CityCoordinates = CityCoordinates(latitude: "42.0016", longitute: "21.4302"),
        cityBorderPoints: [CityCoordinates] = [],
        intialZoomLevel: Int = 15) {
        self.cityName = cityName
        self.siteName = siteName
        self.siteTitle = siteTitle
        self.siteURL = siteURL
        self.countryCode = countryCode
        self.countryName = countryName
        self.cityBorderPoints = cityBorderPoints
        self.cityLocation = cityLocation
        self.intialZoomLevel = intialZoomLevel
        
    }
    static func defaultCity() -> City {
        
        let cityBorderPoints = [CityCoordinates(latitude: "42.04602", longitute: "21.4383023"),
                                CityCoordinates(latitude: "42.055145", longitute: "21.376596"),
                                CityCoordinates(latitude: "42.052561",longitute: "21.3379023"),
                                CityCoordinates(latitude: "42.009616",longitute: "21.324233"),
                                CityCoordinates(latitude: "41.981676",longitute: "21.340713"),
                                CityCoordinates(latitude: "41.959213",longitute: "21.395816"),
                                CityCoordinates(latitude: "41.937931",longitute: "21.422112"),
                                CityCoordinates(latitude: "41.946064",longitute: "21.456927"),
                                CityCoordinates(latitude: "41.905275",longitute: "21.518029"),
                                CityCoordinates(latitude: "41.977848",longitute: "21.721801"),
                                CityCoordinates(latitude: "42.046977",longitute: "21.659659"),
                                CityCoordinates(latitude: "42.032188",longitute: "21.491431"),
                                CityCoordinates(latitude: "42.023772",longitute: "21.555633"),
                                CityCoordinates(latitude: "41.928439",longitute: "21.3648833"),
                                CityCoordinates(latitude: "41.88039992692813",longitute: "21.59568786621094"),
                                CityCoordinates(latitude: "41.914643492538715",longitute: "21.665725708007816"),
                                CityCoordinates(latitude: "41.93993104859892",longitute: "21.695251464843754")]
        
        return City(cityBorderPoints: cityBorderPoints)
    }
    
}

struct CityCoordinates: Codable {
    let latitude, longitute: String
}



