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
    
    let borderColor = #colorLiteral(red: 0.06629675627, green: 0.06937607378, blue: 0.3369944096, alpha: 1)
    
    var date: Date
    var value: String
    var color: String
    var highlighted: Bool = false

    var opacity: Double {
        if date > Date.now {
            return 0.5
        }
        else {
            return 1.0
        }
    }
    
    func labelFromDate(_ date: Date) -> String {
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        else if Calendar.current.isDayInCurrentWeek(date: date) {
            
            let dayOfWeek =  Calendar.current.dateComponents([.weekday], from: date).weekday!
            return Calendar.current.weekdayNameFrom(weekdayNumber: dayOfWeek)
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            return dateFormatter.string(from: date)
        }
    }
    var body: some View {
        
        LazyHStack {
                Button {
                    
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
        let currentComponents = Calendar.current.dateComponents([.weekOfYear], from: Date())
        let dateComponents = Calendar.current.dateComponents([.weekOfYear], from: date)
        guard let currentWeekOfYear = currentComponents.weekOfYear, let dateWeekOfYear = dateComponents.weekOfYear else { return false }
        return currentWeekOfYear == dateWeekOfYear
    }
    
    func weekdayNameFrom(weekdayNumber: Int) -> String {
        let dayIndex = ((weekdayNumber - 1) + (self.firstWeekday - 1)) % 7
        return self.shortWeekdaySymbols[dayIndex]
    }
}
