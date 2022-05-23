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
    
    @StateObject private var viewModel: CalendarViewModel
    @State private var pickerType: PickerType = .day
    @Binding var showingCalendar: Bool
    
    init(showingCalendar: Binding<Bool>, viewModelClosure: @autoclosure @escaping () -> CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModelClosure())
        _showingCalendar = showingCalendar
    }
    
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
        .onChange(of: [viewModel.currentMonthOffset, viewModel.selectedYear]) { _ in
            viewModel.currentDate = viewModel.getCurrentMonth()
            viewModel.dateValues = viewModel.extractDate()
        }
        .padding(.all)
        .background(Color.white)
        .onAppear {
            viewModel.dateValues = viewModel.extractDate()
        }
    }
    
    @ViewBuilder
    private func calendarDaysView(value: DateValueModel, color: String) -> some View {
        
        VStack {
            
            let isDateToday = viewModel.calendar.isDate(value.date,
                                                        equalTo: Date.now,
                                                        toGranularity: .day)
            if value.day != -1 {
                Button {
                    
                } label: {
                    CalendarButtonView(day: value.day,
                                       date: value.date,
                                       color: color,
                                       isDateToday: isDateToday)
                }
            }
        }
        .padding(.vertical, 5)
        .frame(height: 20, alignment: .top)
    }
    
    @ViewBuilder
    var dayPicker: some View {
        
        VStack {
            monthSelectionStack
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(viewModel.daysOfWeekShort, id: \.self) { day in
                        Text( String(day.prefix(1)).capitalized )
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(AppColors.greyColor))
                    }
                }
                HStack(spacing: 0) {
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.dateValues, id: \.id) { value in
                            calendarDaysView(value: value, color: value.color)
                        }
                    }
                }
            }
            okAndCancelStack
        }
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
                    Text("\(viewModel.extraDate().capitalized)")
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
                    viewModel.nextMonth()
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
                    viewModel.previousMonth()
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
        
        let currentYear = viewModel.calendar.component(.year, from: Date())
        let years = 2017...currentYear
        
        VStack {
            HStack {
                Button {
                    pickerType = .year
                } label: {
                    Text(" ")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(AppColors.greyColor))
                }
                Spacer()
            }
            .padding(.top, 0)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 4)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(years, id: \.self) { year in
                    Button {
                        pickerType = .day
                        viewModel.selectedYear = year
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
            .padding(.top)
            
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
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var monthPicker: some View {
        VStack {
            HStack {
                Button {
                    pickerType = .year
                } label: {
                    Text("" + "\(viewModel.selectedYear)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(AppColors.greyColor))
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(Color(AppColors.greyColor))
                        .imageScale(.small)
                }
                Spacer()
            }
            .padding(.top, 0)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 4)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.calendar.shortMonthSymbols, id: \.self) { month in
                    let highlighted: Bool = {
                        if viewModel.calendar.shortMonthSymbols.firstIndex(of: month) == viewModel.selectedMonth - 1 {
                            return true
                        }
                        return false
                    }()
                    Button {
                        viewModel.selectNewMonth(month: month)
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
            .padding(.top)
            
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
        }
        .padding(.top)
    }
}
