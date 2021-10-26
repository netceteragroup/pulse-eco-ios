//
//  Country.swift
//  PulseEco
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation

struct Country: Hashable, Identifiable {
    var id: String { shortName }

    var flagImageName: String
    var languageName: String
    var shortName: String
}
