//
//  CalendarViewModel.swift
//  PulseEco
//
//  Created by Stefan Lazarevski on 17.5.22.
//

import Combine
import Foundation

class CalendarViewModel: ViewModelProtocol {
    
    @Published var monthlyData: [DayDataWrapper] = []
    @Published var currentDate: Date = Date()
    @Published var currentMonthOffset = 0
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var dateValues: [DateValueModel] = []
    
    private let appState: AppState
    private let appDataSource: AppDataSource
    private var cancelables = Set<AnyCancellable>()
    
    var calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: Trema.appLanguageLocale)
        return cal
    }()
    
    init(appState: AppState, appDataSource: AppDataSource) {
        self.appState = appState
        self.appDataSource = appDataSource
        
        self.appDataSource.$monthlyData.sink {
            self.monthlyData = $0
            self.dateValues = self.extractDate()
        }
        .store(in: &cancelables)
    }
    
    func getCurrentMonth() -> Date {
        
        let yearOffset = self.selectedYear - Calendar.current.component(.year, from: Date())
        
        guard let newDate = calendar.date(byAdding: .year,
                                          value: yearOffset,
                                          to: Date()) else {
            return Date()
        }
        
        guard let currentMonth = calendar.date(byAdding: .month,
                                               value: currentMonthOffset,
                                               to: newDate) else {
            return Date()
        }
        
        return currentMonth
    }
    
    func extractDate() -> [DateValueModel] {
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getDaysOfMonth().compactMap { date -> DateValueModel in
            var color = "gray"
            let day = calendar.component(.day, from: date)
            for element in monthlyData where isSameDay(date1: element.date, date2: date) {
                color = element.color
            }
            return DateValueModel(day: day,
                                  date: date,
                                  color: color)
        }
        let firstWeekDay: Int = {
            let first = calendar.component(.weekday, from: days.first?.date ?? Date()) - 1
            return first > 0 ? first : 7
        }()
        for _ in 1..<firstWeekDay {
            days.insert(DateValueModel(day: -1, date: Date(), color: "gray"), at: 0)
        }
        
        return days
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = calendar.dateComponents([.day], from: date1, to: date2)
        return diff.day == 0
    }
    
    var daysOfWeekShort: [String] = {
        
        return [
            Trema.text(for: "monday-short"),
            Trema.text(for: "tuesday-short"),
            Trema.text(for: "wednesday-short"),
            Trema.text(for: "thursday-short"),
            Trema.text(for: "friday-short"),
            Trema.text(for: "saturday-short"),
            Trema.text(for: "sunday-short")
        ]
    }()
    
    func extraDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        formatter.locale = Locale(identifier: Trema.appLanguageLocale)
        
        let date = formatter.string(from: currentDate)
        
        return date
    }
    
    func nextMonth() {
        if selectedMonth < 1 {
            selectedMonth += 11
            selectedYear -= 1
        }
        currentMonthOffset -= 1
        selectedMonth -= 1
        currentMonthOffset = selectedMonth - Calendar.current.component(.month, from: Date())
    }
    func previousMonth() {
        if selectedMonth > 10 {
            selectedMonth -= 11
            selectedYear += 1
        }
        currentMonthOffset += 1
        selectedMonth += 1
        currentMonthOffset = selectedMonth - Calendar.current.component(.month, from: Date())
    }
    func selectNewMonth(month: String) {
        selectedMonth = calendar.shortMonthSymbols.firstIndex(of: month) ?? selectedMonth
        currentMonthOffset = selectedMonth - Calendar.current.component(.month, from: Date()) + 1
    }
}

private extension Date {
    func getDaysOfMonth() -> [Date] {
        
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
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
