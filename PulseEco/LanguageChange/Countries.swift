//
//  Countries.swift
//  PulseEco
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation

class Countries {

    static func countries(language: String) -> [Country] {
        return  [Country(flagImageName: "",
                         languageName: Trema.text(for: "english", language: language),
                         shortName: "en"),
                 Country(flagImageName: "",
                         languageName: Trema.text(for: "macedonian", language: language),
                         shortName: "mk"),
                 Country(flagImageName: "",
                         languageName: Trema.text(for: "german", language: language),
                         shortName: "de"),
                 Country(flagImageName: "",
                         languageName: Trema.text(for: "romanian", language: language),
                         shortName: "ro")]
    }

    static func selectedCountry(for language: String) -> Country {
        let allCountries = countries(language: language)
        return allCountries.filter { $0.shortName ==  language }.first ?? allCountries[0]
    }
}
