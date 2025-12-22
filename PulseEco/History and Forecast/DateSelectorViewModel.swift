//
//  DateSelectorViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 15.1.25.
//

import Foundation
import Factory

@MainActor
class DateSelectorViewModel: ObservableObject {
    @Injected(\.appData) private var appData: AppDataProtocol
    @Published var isDatePickerPressed: Bool = false
    var selectedDate: Date = Date()
    var searchButtonTask: Task<(), Never>?
    var onSelectedMeasureChange: Task<(), Never>?
    
    func shortDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        let formattedDate = formatter.string(from: date)
        return formattedDate
    }
    
    func setAppData(showingCalendar: Bool) {
        guard showingCalendar != appData.showingCalendar else { return }
        appData.showingCalendar = showingCalendar
    }
    
    func setAppData(selectedDate: Date) {
        guard selectedDate != appData.selectedDate else { return }
        appData.selectedDate = selectedDate
    }

}
