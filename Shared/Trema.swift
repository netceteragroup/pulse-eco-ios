//
//  Trema.swift
//  PulseEco
//
//  Created by Maja Mitreska on 29.3.21.
//

import Foundation
import SwiftUI

class Trema {
    static var appLanguage: String {
        get {
            UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        }
        set (toLanguage) {
            UserDefaults.standard.set(toLanguage, forKey: "AppLanguage")
        }
    }

    static func text(for key: String,
                     language: String = appLanguage) -> String {
        key.localizedFor(language)
    }
    
    static var appLanguageLocale: String {
        let lang = appLanguage
        switch lang {
        case "rs": return "sr_Latn_RS"
        default: return lang
        }
    }
}

private extension String {
    func localizedFor(_ language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return self
        }
        let bundle = Bundle(path: path)
        return bundle?.localizedString(forKey: self, value: nil, table: "messages") ?? self
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
