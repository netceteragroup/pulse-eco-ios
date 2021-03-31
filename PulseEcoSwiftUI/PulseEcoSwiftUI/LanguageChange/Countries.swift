//
//  Countries.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation

class Countries {
    
    static func countries(language: String) -> [Country] {
        return  [Country(flagImageName: "🇬🇧",
                         languageName: Trema.text(for: "english", lang: language),
                         shortName: "en"),
                 Country(flagImageName: "🇲🇰",
                         languageName: Trema.text(for: "macedonian", lang: language),
                         shortName: "mk"),
                 Country(flagImageName: "🇩🇪",
                         languageName: Trema.text(for: "german", lang: language),
                         shortName: "de")]
    }
    
    static func selectedCountry(for language: String) -> Country {
        let allCountries = countries(language: language)
        return allCountries.filter{$0.shortName ==  language}.first ?? allCountries[0]
    }
}
