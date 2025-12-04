//
//  UserDefaultsEnumWrapper.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 16.2.23.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<Value: Encodable & Decodable> {
    let key: String
    let defaultValue: Value
    let container: UserDefaults
    let shouldCache: Bool
    
    private var cachedValue: Value?
    
    init(key: String, defaultValue: Value, container: UserDefaults = .standard, shouldCache: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
        self.shouldCache = shouldCache
    }
    
    var wrappedValue: Value {
        mutating get {
            if shouldCache, let cachedValue {
                return cachedValue
            }
            guard let data = container.data(forKey: key), let decodedData = try? JSONDecoder().decode(Value.self, from: data) else { return defaultValue }
            cachedValue = decodedData
            return decodedData
        }
        set {
            if shouldCache {
                cachedValue = newValue
            }
            let encodedValue = try? JSONEncoder().encode(newValue)
            container.set(encodedValue, forKey: key)
        }
    }
}

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
