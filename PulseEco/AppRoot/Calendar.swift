import Foundation

/// Global variable to use instead of Calendar.current
public var calendar: Calendar {
    var cal = Calendar(identifier: .iso8601)
    cal.locale = Locale(identifier: Trema.appLanguageLocale)
    return cal
}
