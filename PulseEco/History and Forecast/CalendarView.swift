//
//  CustomCalendar.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 26.4.22.
//

import SwiftUI

private enum PickerType {
    case day, month, year
}
struct CalendarView: View {
    
    @State private var currentDate: Date = Date()
    @State private var currentMonthOffset = 0
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1
//    @State private var newMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var pickerType: PickerType = .day
    @State private var dateValues: [DateValueModel] = []
    @Binding var showingCalendar: Bool
    @StateObject private var viewModel: CalendarViewModel
    
    init(showingCalendar: Binding<Bool>, viewModelClosure: @autoclosure @escaping () -> CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModelClosure())
        _showingCalendar = showingCalendar
    }
    
    private var calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: Trema.appLanguageLocale)
        return cal
    }()
    
    var body: some View {
        
        VStack(spacing: 10) {
            switch pickerType {
            case .day:
                dayPicker
            case .month:
                monthPicker
            case .year:
                yearPicker
            }
        }
        .onChange(of: currentMonthOffset) { _ in
            currentDate = getCurrentMonth()
            dateValues = extractDate()
        }
        .padding(.all)
        .background(Color.white)
        .onAppear {
            dateValues = extractDate()
        }
    }
    
    @ViewBuilder
    private func calendarDaysView(value: DateValueModel, color: String) -> some View {
        
        VStack {
            
            let isDateToday = calendar.isDate(value.date, equalTo: Date.now, toGranularity: .day)
            if value.day != -1 {
                
                Button {
                    
                } label: {
                    CalendarButtonView(day: value.day, date: value.date, color: color, isDateToday: isDateToday)
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
    
    private var daysOfWeekShort: [String] = {
        
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
    
    func getCurrentMonth() -> Date {
        guard let currentMonth = calendar.date(byAdding: .month,
                                               value: self.currentMonthOffset,
                                               to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
    private func extractDate() -> [DateValueModel] {
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getDaysOfMonth().compactMap { date -> DateValueModel in
            var color = "gray"
            let day = calendar.component(.day, from: date)
            for element in viewModel.monthlyData where isSameDay(date1: element.date, date2: date) {
                color = element.color
            }
            return DateValueModel(day: day, date: date, color: color)
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
    
    @ViewBuilder
    var dayPicker: some View {
        
        monthSelectionStack
        
        VStack {
            HStack(spacing: 0) {
                ForEach(daysOfWeekShort, id: \.self) { day in
                    Text( String(day.prefix(1)).capitalized )
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(AppColors.greyColor))
                }
            }
            HStack(spacing: 0) {
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(dateValues, id: \.id) { value in
                        calendarDaysView(value: value, color: value.color)
                    }
                }
            }
        }
        okAndCancelStack
    }
    
    private var okAndCancelStack: some View {
        HStack {
            Spacer()
            Button {
                showingCalendar = false
            } label: {
                Text(Trema.text(for: "cancel"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.greyColor))
            }
            .padding(.top)
            
            Button {
                showingCalendar = false
            } label: {
                Text(Trema.text(for: "ok"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.firstButtonColor))
            }
            .padding(.top)
        }
        .padding(.all)
    }
    
    @ViewBuilder
    private var monthSelectionStack: some View {
        HStack {
            Button {
                pickerType = .month
            } label: {
                HStack {
                    Text("\(extraDate().capitalized)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(AppColors.greyColor))
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(Color(AppColors.greyColor))
                        .imageScale(.small)
                }
            }
            Spacer(minLength: 0)
            
            Button {
                withAnimation {
                    currentMonthOffset -= 1
                    selectedMonth -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .foregroundColor(Color(AppColors.chevronColor))
                    .frame(width: 7.41, height: 12)
            }
            .padding(.all)
            
            Button {
                withAnimation {
                    currentMonthOffset += 1
                    selectedMonth += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(Color(AppColors.chevronColor))
                    .frame(width: 7.41, height: 12)
            }
            .padding(.all)
        }
    }
    
    @ViewBuilder
    private var yearPicker: some View {
        
        let currentYear = calendar.component(.year, from: currentDate)
        let years = 2017...currentYear
        
        LazyVStack {
            let columns = Array(repeating: GridItem(.flexible()), count: 4)
            Spacer()
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(years, id: \.self) { year in
                    Button {
                        pickerType = .day
                        selectedYear = year
//                        if newMonth != selectedMonth {
//                            pickerType = .month
//                        }
                    } label: {
                        Text(String(year))
                            .font(.system(size: 14, weight: .regular))
                            .frame(alignment: .center)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(AppColors.pickerColor))
                            .clipShape(Circle())
                    }
                }
            }
            .frame(maxHeight: .infinity)
            Spacer()
                .frame(height: 150)
            HStack {
                Spacer()
                Button {
                    pickerType = .day
                } label: {
                    Text(Trema.text(for: "cancel"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(AppColors.greyColor))
                }
                .padding(.top)
            }
            .padding(.all)
            .frame(maxHeight: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 350)
    }
    
    @ViewBuilder
    private var monthPicker: some View {
        
        let monthsArray = calendar.shortMonthSymbols
        LazyVStack {
            HStack {
                Button {
                    pickerType = .year
                } label: {
                    Text("" + "\(selectedYear)")
                        .font(.system(size: 14, weight: .regular))
                        .frame(alignment: .center)
                        .foregroundColor(Color(AppColors.black))
                        .padding(.all)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
            HStack(spacing: 0) {
                let columns = Array(repeating: GridItem(.flexible()), count: 4)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(monthsArray, id: \.self) { month in
                        let highlighted: Bool = {
                            if monthsArray.firstIndex(of: month) == selectedMonth {
                                return true
                            }
                            return false
                        }()
                        Button {
                            selectedMonth = monthsArray.firstIndex(of: month) ?? selectedMonth
//                            newMonth = selectedMonth
                            pickerType = .day
                        } label: {
                            Text(String(month.capitalized))
                                .font(.system(size: 14, weight: .regular))
                                .frame(alignment: .center)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(AppColors.pickerColor))
                                .clipShape(Circle())
                                .overlay(highlighted ?
                                         Circle() .stroke(Color(AppColors.borderColor), lineWidth: 1) : nil)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            HStack {
                Spacer()
                Button {
                    pickerType = .day
                } label: {
                    Text(Trema.text(for: "cancel"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(AppColors.greyColor))
                }
                .padding(.top)
            }
            .padding(.all)
            .frame(maxHeight: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 350)
    }
}

private extension Date {
    func getDaysOfMonth() -> [Date] {
        
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
