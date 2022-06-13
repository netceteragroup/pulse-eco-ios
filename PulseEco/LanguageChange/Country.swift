//
//  Country.swift
//  PulseEco
//
//  Created by Maja Mitreska on 29.3.21.
//

import Foundation

struct Country: Hashable, Identifiable {
    var id: String { shortName }

    var flagImageName: String
    var languageName: String
    var shortName: String
}
