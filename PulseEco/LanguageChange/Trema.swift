//
//  Trema.swift
//  PulseEco
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
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
