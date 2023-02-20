//
//  UserDefaultsEnumWrapper.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 16.2.23.
//

import Foundation


@propertyWrapper
struct UserDefaultsEnumWrapper<Value: RawRepresentable> {
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            if let savedObject = container.object(forKey: key) as? Value.RawValue,
               let result = Value(rawValue: savedObject) {
                return result
            } else {
                return defaultValue
            }
        }
        set {
            container.set(newValue.rawValue, forKey: key)
        }
    }
}
