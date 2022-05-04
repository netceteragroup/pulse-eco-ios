//
//  CustomCalendar.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 26.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct CustomCalendar: View {
    
    @State var currentDate: Date = Date()
    @State var currentMonth: Int = 0
    
    @Binding var showingCalendar: Bool
    @Binding var showPicker: Bool
    
    @State var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    
    var calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: Trema.appLanguageLocale)
        return cal
    }()
    
    let firstButtonColor = #colorLiteral(red: 0.05490196078, green: 0.03921568627, blue: 0.2666666667, alpha: 1)
    let greenColor = #colorLiteral(red: 0.3035327792, green: 0.6464360356, blue: 0.4156317115, alpha: 1)
    let orangeColor = #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1)
    let redColor = #colorLiteral(red: 0.6941176471, green: 0.168627451, blue: 0.2196078431, alpha: 1)
    let greyColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
    let chevronColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54)
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            if !showPicker {
                calendarPicker
            } else {
                datePicker
            }
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
        }
        .padding(.all)
        .background(Color.white)
    }
    
    @ViewBuilder
    private func cardView(value: DateValueModel) -> some View {
        
        VStack {
            
            let flag = Calendar.current.isDate(value.date, equalTo: Date.now, toGranularity: .day)
            
            if value.day != -1 {
                
                Button {
                    
                } label: {
                    Text("\(value.day)")
                        .font(.system(size: 14, weight: .regular))
                        .frame(maxWidth:. infinity)
                        .foregroundColor(flag ? Color.white : Color(redColor))
                        .frame(width: 30, height: 30)
                        .overlay(Circle()
                            .stroke(Color(redColor), lineWidth: 1) )
                        .background(flag ?
                                    Circle()
                            .fill(Color(redColor)) : nil )
                }
            }
        }
        .padding(.vertical, 5)
        .frame(height: 20, alignment: .top)
    }
    
    private func extraDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        formatter.locale = Locale(identifier: Trema.appLanguageLocale)
        
        let date = formatter.string(from: currentDate)
        
        return date
    }
    
    private func daysOfWeekShort() -> [String] {
        let arrey = [
            Trema.text(for: "monday-short"),
            Trema.text(for: "tuesday-short"),
            Trema.text(for: "wednesday-short"),
            Trema.text(for: "thursday-short"),
            Trema.text(for: "friday-short"),
            Trema.text(for: "saturday-short"),
            Trema.text(for: "sunday-short")
        ]
        
        return arrey
            .map {
                String($0.prefix(1)).capitalized
            }
    }
    
    private func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    private func extractDate() -> [DateValueModel] {
        
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValueModel in
            
            let day = calendar.component(.day, from: date)
            
            return DateValueModel(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValueModel(day: -1, date: Date()), at: 0)
        }
        return days
    }
    
    @ViewBuilder
    var calendarPicker: some View {
        
        let days: [String] = daysOfWeekShort()
        
        HStack() {
            
            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text("\(extraDate().capitalized)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(greyColor))
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(Color(greyColor))
                        .imageScale(.small)
                }
            }
            Spacer(minLength: 0)
            
            Button {
                withAnimation {
                    currentMonth -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .foregroundColor(Color(chevronColor))
                    .frame(width: 7.41, height: 12)
            }
            .padding(.all)
            
            Button {
                withAnimation {
                    currentMonth += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(Color(chevronColor))
                    .frame(width: 7.41, height: 12)
            }
            .padding(.all)
        }
        
        VStack {
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(greyColor))
                }
            }
            
            HStack(spacing: 0) {
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(extractDate()) { value in
                        cardView(value: value)
                            .onTapGesture {
                                currentDate = value.date
                            }
                    }
                }
            }
        }
        
        HStack() {
            
            Spacer()
            
            Button {
                showingCalendar = false
            } label: {
                Text(Trema.text(for: "cancel"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(greyColor))
            }
            .padding(.top)
            
            Button {
                showingCalendar = false
            } label: {
                Text(Trema.text(for: "ok"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(firstButtonColor))
            }
            .padding(.top)
        }
        .padding(.all)
        
    }
    
    @ViewBuilder
    var datePicker: some View {
        
        let currentYear = calendar.component(.year, from: currentDate)
        let monthsArray = calendar.monthSymbols
        
        GeometryReader { proxy in
            VStack {
                HStack (spacing: 0) {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(0..<monthsArray.count, id: \.self) { month in
                            Text(monthsArray[month].capitalized)
                                .font(.system(size: 14, weight: .regular))
                                .frame(alignment: .center)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 180, alignment: .center)
                    .clipped()
//                    .frame(width: proxy.size.width/2, alignment: .center)
                   
//                    Spacer(minLength: 0)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2000...currentYear+1, id: \.self) {
                            Text(String($0))
                                .font(.system(size: 14, weight: .regular))
                                .frame(alignment: .center)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 180, alignment: .center)
                    .clipped()
//                    .frame(width: proxy.size.width/2, alignment: .center)
                }
                .onAppear {
                }
                HStack {
                    Button {
                        showingCalendar = true
                        showPicker = false
                    } label: {
                        Text(Trema.text(for: "cancel"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(greyColor))
                    }
                    .padding(.top)
                    
                    Button {
                        showingCalendar = true
                        showPicker = false
                    } label: {
                        Text(Trema.text(for: "ok"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(firstButtonColor))
                    }
                    .padding(.top)
                }
            }
        }
        .frame(height: 280)
    }
}

extension Date{
    
    func getAllDates()->[Date] {
        
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day->Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
