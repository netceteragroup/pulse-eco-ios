//
//  DateSelectorViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 15.1.25.
//

import Foundation

@MainActor
class DateSelectorViewModel: ObservableObject {
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
}
