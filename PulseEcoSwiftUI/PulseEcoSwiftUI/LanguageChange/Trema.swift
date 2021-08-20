//
//  Trema.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class Trema {
    
    static var appLanguage: String {
        UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
    }
    
    static func text(for key: String,
                     language: String = appLanguage) -> String {
        if let path = Bundle.main.path(forResource: "translations", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            let translations = dict[key] as? [String:String]
            return translations?[language] ?? key
        }
        return key
    }
    
}
