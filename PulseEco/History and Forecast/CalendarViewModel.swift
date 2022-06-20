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
    @Published var selectedYear: Int = calendar.component(.year, from: Date())
    @Published var selectedMonth: Int = calendar.component(.month, from: Date())
    @Published var dateValues: [DateValueModel] = []
    @Published var monthValues: [DayDataWrapper] = []
    
    private let appState: AppState
    let appDataSource: AppDataSource
    private var cancelables = Set<AnyCancellable>()
    
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
        
        let yearOffset = self.selectedYear - calendar.component(.year, from: Date())
        
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
            Trema.text(for: "sunday-short")]
    }()
    
    func extraDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        formatter.locale = Locale(identifier: Trema.appLanguageLocale)
        
        let date = formatter.string(from: currentDate)
        
        return date
    }
    
    func previousMonth() {
        let yearChange = selectedMonth == 1
        if yearChange {
            selectedMonth += 11
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
        currentMonthOffset -= 1
        currentMonthOffset = selectedMonth - calendar.component(.month, from: Date())
        if yearChange {
            Task {
                await appDataSource.updateMonthlyColors(selectedYear: selectedYear)
                colorMonths()
            }
        }
        Task {
            await appDataSource.fetchMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
        }
    }
    func nextMonth() async {
        let yearChange = selectedMonth >= 11
        if yearChange {
            selectedMonth -= 11
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
        currentMonthOffset += 1
        currentMonthOffset = selectedMonth - calendar.component(.month, from: Date())
        if yearChange {
            Task {
                await appDataSource.updateMonthlyColors(selectedYear: selectedYear)
                colorMonths()
            }
        }
        Task {
            await appDataSource.fetchMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
        }
    }
    func selectNewMonth(month: String) async {
        selectedMonth = calendar.shortMonthSymbols.firstIndex(of: month) ?? selectedMonth
        currentMonthOffset = selectedMonth - calendar.component(.month, from: Date())
        await nextMonth()
    }
    
    func colorMonths() {
        let currentYear = selectedYear
        let from = Date.from(1, 1, currentYear)!
        let to = Date.from(31, 12, currentYear)!
        
        monthValues = appDataSource.monthlyAverage.getDataFromRange(cityName: appState.selectedCity.cityName, sensorType: appState.selectedMeasureId, from: from, to: to)
        let allMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ,12]
        var containing:[Int] = []
        for val in monthValues {
            containing.append(val.month)
        }
        
        let missingMonths = allMonths.difference(from: containing)
        for month in missingMonths {
            monthValues.append(DayDataWrapper(date: Date.from(1, month, currentYear)!, value: "", color: "darkblue"))
        }
        monthValues = monthValues.sorted(by: { $0.month < $1.month})
        Task {
            await appDataSource.fetchMonthlyData(selectedMonth: selectedMonth, selectedYear: selectedYear)
        }
    }
}
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
