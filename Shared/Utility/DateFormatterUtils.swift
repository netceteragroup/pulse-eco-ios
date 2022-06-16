import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let getDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let getTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let getDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    static func from(_ day: Int, _ month: Int, _ year: Int) -> Date? {
        let calendar = Calendar(identifier: .iso8601)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 00
        dateComponents.minute = 00
        dateComponents.second = 00
        dateComponents.timeZone = TimeZone(secondsFromGMT: 7200)
        return calendar.date(from: dateComponents) ?? nil
    }
    
    func isSameDay(with date: Date) -> Bool {
        let components1 = calendar.dateComponents([.day, .month, .year], from: self)
        let components2 = calendar.dateComponents([.day, .month, .year], from: date)
        return components1 == components2
    }
}

extension Date {
    func getDaysOfMonth() -> [Date] {
        
        let calendar = calendar
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day,
                                   in: .month,
                                   for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day,
                                 value: day - 1,
                                 to: startDate)!
        }
    }
}
