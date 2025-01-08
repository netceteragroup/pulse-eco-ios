//
//  DatePicker.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 25.12.24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DatePickerViewModel: ObservableObject {
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

struct DatePicker: View {
    @StateObject private var viewModel = DatePickerViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appDataSource: AppDataSource
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.isDatePickerPressed.toggle()
                }) {
                    HStack {
                        Text(calendar.isDateInToday(appState.selectedDate) ? Trema.text(for: "today") : viewModel.shortDate(date: appState.selectedDate))
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.trailing, 8)
                    }
                    .padding(.vertical, 15)
                    .font(.caption)
                    .foregroundStyle(Color(AppColors.firstButtonColor))
                    .border(Color(AppColors.firstButtonColor))
                    .frame(maxWidth: .infinity)
                }
                
                
                Button(action: {
                    viewModel.searchButtonTask?.cancel()
                    viewModel.searchButtonTask = Task {
                        await appDataSource.selectFromCalendar()
                    }
                    viewModel.isDatePickerPressed = false
                }) {
                    Text("SEARCH") //add trema
                        .padding(.vertical, 15)
                        .padding(.horizontal, 45)
                        .background(Color(AppColors.firstButtonColor))
                        .foregroundStyle(Color.white)
                        .font(.caption)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .frame(maxWidth: .infinity)
            
            if viewModel.isDatePickerPressed {
                VStack {
                    HStack {
                        CalendarView(showingCalendar: $viewModel.isDatePickerPressed,
                                     selectedDate: $appState.selectedDate,
                                     calendarSelection: $appState.calendarSelection,
                                     onDaySelected: { newDate in viewModel.selectedDate = newDate },
                                     viewModelClosure: CalendarViewModel(appState: self.appState,
                                                                         appDataSource: self.appDataSource))
                        .onChange(of: appState.selectedMeasureId) { newValue in
                            viewModel.isDatePickerPressed = false
                            viewModel.onSelectedMeasureChange?.cancel()
                            viewModel.onSelectedMeasureChange = Task {
                                await appDataSource.fetchMonthlyDayData(selectedMonth: calendar.component(.month, from: viewModel.selectedDate), selectedYear: calendar.component(.year, from: viewModel.selectedDate))
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        DatePicker()
            .padding(.horizontal)
            .padding(.vertical, 8)
        
        Spacer()
    }
}
