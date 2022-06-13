import Foundation


/// Global variable to use instead of Calendar.current
public var calendar: Calendar {
    var cal = Calendar.current
    cal.locale = Locale(identifier: Trema.appLanguageLocale)
    return cal
}
