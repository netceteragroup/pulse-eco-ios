//
//  DayDataWrapper.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 11.5.22.
//

import Foundation

struct DayDataWrapper: Hashable {
    let date: Date
    let value: String
    let color: String
    
    var dateId: Date {
        calendar.startOfDay(for: date)
    }
    var month: Int {
        calendar.dateComponents([.month], from: date).month!
    }
    var monthName: String {
        Trema.text(for: DateFormatter().monthSymbols[month - 1])
    }
}
