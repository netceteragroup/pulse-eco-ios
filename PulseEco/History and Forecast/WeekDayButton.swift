//
//  WeekDayButton.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 20.4.22.
//

import SwiftUI
import Charts

struct WeekDayButton: View {
    
    var date: Date
    var value: String
    var color: String

    var opacity: Double {
        if date > Date.now {
            return 0.5
        } else {
            return 1.0
        }
    }
    
    var highlighted: Bool = false
    var action: () -> Void
    
    var sevenDaysAgo = calendar.date(byAdding: .day,
                                             value: -6,
                                             to: calendar.startOfDay(for: Date.now))
    
    func labelFromDate(_ date: Date) -> String {
        
        if calendar.isDateInToday(date) {
            return Trema.text(for: "today")
        } else if date > sevenDaysAgo! {
            let dayOfWeek = calendar.dateComponents([.weekday], from: calendar.startOfDay(for: date)).weekday!
            return calendar.weekdayNameFrom(weekdayNumber: dayOfWeek).capitalized
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Trema.appLanguageLocale)
            dateFormatter.dateFormat = "dd MMM"
            return dateFormatter.string(from: date).capitalized
        }
    }
    
    var body: some View {
        
        HStack {
                Button {
                    action()
                } label: {
                    VStack(spacing: 3) {
                        Text(labelFromDate(date))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(AppColors.black))
                        
                        Text(value)
                            .font(.system(size: 10, weight: .regular))
                            .frame(width: 34, height: 12, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color(color)))
                    }
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(AppColors.white))
                    .background(Color(AppColors.white))
                    .cornerRadius(3)
                }
                .opacity(opacity)
                .overlay((self.highlighted) ?
                         RoundedRectangle(cornerRadius: 3) .stroke(Color(AppColors.borderColor), lineWidth: 1) : nil)
        }
    }
}

extension Calendar {
    func weekdayNameFrom(weekdayNumber: Int) -> String {
        let dayIndex = (weekdayNumber - 1) % 7
        return self.shortWeekdaySymbols[dayIndex]
    }
}
