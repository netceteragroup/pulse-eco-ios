import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultOptional<T> {
    let key: String

    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultCoded<T> where T: Codable {
    let key: String
    
    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: T? {
        get {
            let data = UserDefaults.standard.object(forKey: key) as? Data
            if let data = data {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error).")
                }
            }
            return nil
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                print("Encoding error: \(error).")
            }
        }
    }
}
