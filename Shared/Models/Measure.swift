//
//  Measure.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/11/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

struct Measure: Codable, Identifiable {
    var id: String
    let buttonTitle: String
    let title: String
    let icon: String
    let description: String
    let showMin: Int
    let showMax: Int
    let legendMin: Int
    let legendMax: Int
    let unit: String
    let showMessages: Bool
    let bands: [Band]
    
    enum CodingKeys: String, CodingKey {
        case id, buttonTitle, title, icon
        case description
        case showMin, showMax, legendMin, legendMax, unit, showMessages, bands
    }
    
    static func empty(id: String = "--", _ title: String = "--") -> Measure {
        Measure(id: id,
                buttonTitle: title,
                title: "--",
                icon: "wifi",
                description: "--",
                showMin: 0,
                showMax: NSIntegerMax,
                legendMin: 0,
                legendMax: 100,
                unit: "--",
                showMessages: false,
                bands: [Band.empty()])
    }
    
    static var dummy: Measure {
        let bands = [
            Band(from: 0,
                 to: 25,
                 legendPoint: 0,
                 legendColor: "green",
                 markerColor: "green",
                 shortGrade: "Good air quality.",
                 grade: "Good air quality. Air quality is considered satisfactory, and air pollution poses little or no risk",
                 suggestion: "No preventive measures needed, enjoy the fresh air."),
            
            Band(from: 26,
                 to: 50,
                 legendPoint: 37,
                 legendColor: "darkgreen",
                 markerColor: "darkgreen",
                 shortGrade: "Moderate air quality.",
                 grade: "Moderate air quality. Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people.",
                 suggestion: "Consider limiting your outside exposure if you're sensitive to bad air."),
            
            Band(from: 51,
                 to: 90,
                 legendPoint: 70,
                 legendColor: "orange",
                 markerColor: "orange",
                 shortGrade: "Bad air quality.",
                 grade: "Bad air quality. Unhealthy for Sensitive Groups, people with heart lung disease, older adults and children.",
                 suggestion: "Limit your outside exposure if you're sensitive to bad air."),
            
            Band(from: 91,
                 to: 180,
                 legendPoint: 135,
                 legendColor: "red",
                 markerColor: "red",
                 shortGrade: "Very bad air quality.",
                 grade: "Very bad air quality. Everyone may begin to experience some adverse health effects, and members of the sensitive groups may experience more serious effects.",
                 suggestion: "Stay indoors if you're sensitive to bad air. Everyone should limit outside exposure"),
            
            Band(from: 181,
                 to: 2000,
                 legendPoint: 200,
                 legendColor: "darkred",
                 markerColor: "darkred",
                 shortGrade: "Hazardous air quality!",
                 grade: "Hazardous air quality! This would trigger a health warnings of emergency conditions. The entire population is more likely to be affected!",
                 suggestion: "Stay indoors as much as possible.")
        ]
        
        return Measure(id: "pm10",
                       buttonTitle: "PM10",
                       title: "Air quality (PM10)",
                       icon: "fa fa-cloud icon-pm10",
                       description: "Suspended particulate matter in air less than 10μm wide.",
                       showMin: 0,
                       showMax: 100,
                       legendMin: 0,
                       legendMax: 200,
                       unit: "μg/m3",
                       showMessages: true,
                       bands: bands)
    }
}

struct Band: Codable {
    let from: Int
    let to: Int
    let legendPoint: Int
    let legendColor: String
    let markerColor: String
    let shortGrade: String
    let grade: String
    let suggestion: String
    
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.legendPoint == rhs.legendPoint
    }
    static func empty() -> Band {
        return Band(from: 0,
                    to: NSIntegerMax,
                    legendPoint: 0,
                    legendColor: "gray",
                    markerColor: "gray",
                    shortGrade: "--",
                    grade: "--",
                    suggestion: "--")
    }
    
    static var dummy: Band {
        Band(from: 0,
             to: 25,
             legendPoint: 0,
             legendColor: "green",
             markerColor: "green",
             shortGrade: "Good air quality.",
             grade: "Good air quality. Air quality is considered satisfactory, and air pollution poses little or no risk",
             suggestion: "No preventive measures needed, enjoy the fresh air.")
    }
}
