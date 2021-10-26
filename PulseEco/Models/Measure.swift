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
    let id: String
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
        return Measure(id: id,
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
}
