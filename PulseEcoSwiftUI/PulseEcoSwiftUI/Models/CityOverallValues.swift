//
//  CityOverallValues.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/10/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation


// MARK: - CityOverallValues

struct CityOverallValues: Codable {
    let cityName: String
    var values: [String: String]
}
