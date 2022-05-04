//
//  WeekDayButton.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 20.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import Charts

struct WeekDayButton: View {
    
    var calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: Trema.appLanguageLocale)
        return cal
    }()
    
    let borderColor = #colorLiteral(red: 0.06629675627, green: 0.06937607378, blue: 0.3369944096, alpha: 1)
    
    var date: Date
    var value: String
    var color: String
    var highlighted: Bool = false

    var opacity: Double {
        if date > Date.now {
            return 0.5
        } else {
            return 1.0
        }
    }
    
    func labelFromDate(_ date: Date) -> String {
        
        if calendar.isDateInToday(date) {
            return Trema.text(for: "today")
        } else if calendar.isDayInCurrentWeek(date: date) {
            
            let dayOfWeek = calendar.dateComponents([.weekday], from: date).weekday!
            return calendar.weekdayNameFrom(weekdayNumber: dayOfWeek).capitalized
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Trema.appLanguageLocale)
            dateFormatter.dateFormat = "dd MMM"
            return dateFormatter.string(from: date).capitalized
        }
    }
    var body: some View {
        
        LazyHStack {
                Button {
                    //TODO: Select date
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
                .overlay(highlighted ?
                    RoundedRectangle(cornerRadius: 3) .stroke(Color(borderColor), lineWidth: 1) : nil)
        }
    }
}

extension Calendar {
    func isDayInCurrentWeek(date: Date) -> Bool {
        let currentComponents = self.dateComponents([.weekOfYear], from: Date())
        let dateComponents = self.dateComponents([.weekOfYear], from: date)
        guard let currentWeekOfYear = currentComponents.weekOfYear, let dateWeekOfYear = dateComponents.weekOfYear else { return false }
        return currentWeekOfYear == dateWeekOfYear
    }
    
    func weekdayNameFrom(weekdayNumber: Int) -> String {
        let dayIndex = ((weekdayNumber - 1) + (self.firstWeekday - 1)) % 7
        return self.shortWeekdaySymbols[dayIndex]
    }
}
