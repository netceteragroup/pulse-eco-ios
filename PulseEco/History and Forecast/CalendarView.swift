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
    
    @EnvironmentObject var dataSource: AppDataSource
    
    @StateObject private var viewModel: CalendarViewModel
    @State private var pickerType: PickerType = .day
    
    @Binding var showingCalendar: Bool
    @Binding var selectedDate: Date
    
    init(showingCalendar: Binding<Bool>,
         selectedDate: Binding<Date>,
         viewModelClosure: @autoclosure @escaping () -> CalendarViewModel) {
        
        _viewModel = StateObject(wrappedValue: viewModelClosure())
        _showingCalendar = showingCalendar
        _selectedDate = selectedDate
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
            
            if value.day != -1 {
                Button {
                    self.selectedDate = calendar.startOfDay(for: value.date)
                    Task {
                        do {
                            await viewModel.appDataSource.updatePins(selectedDate: selectedDate)
                        }
                    }
                    showingCalendar = false
                } label: {
                    CalendarButtonView(day: value.day,
                                       date: value.date,
                                       color: color,
                                       highlighted: value.date.isSameDay(with: selectedDate))
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
                    Task {
                        await viewModel.previousMonth()
                    }
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .foregroundColor(Color(AppColors.chevronColor))
                    .frame(width: 7.41, height: 12)
                    .padding(.leading)
            }
            .padding(.all)
            
            Button {
                    Task {
                        await viewModel.nextMonth()
                    }
            } label: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(Color(AppColors.chevronColor))
                    .frame(width: 7.41, height: 12)
                    .padding(.trailing)
            }
            .padding(.all)
        }
    }
    
    @ViewBuilder
    private var yearPicker: some View {
        
        let currentYear = calendar.component(.year, from: Date())
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
                            .foregroundColor(Color.gray)
                            .padding()
                            .overlay(Circle()
                                .stroke(Color.gray, lineWidth: 1))
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
                ForEach(calendar.shortMonthSymbols, id: \.self) { month in
                    Button {
                        Task {
                            await viewModel.selectNewMonth(month: month)
                        }
                        pickerType = .day
                    } label: {
                        Text(String(month.capitalized))
                            .font(.system(size: 14, weight: .regular))
                            .frame(alignment: .center)
                            .foregroundColor(Color.gray)
                            .padding()
                            .overlay(Circle()
                                .stroke(Color.gray, lineWidth: 1))
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
