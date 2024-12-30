//
//  DatePicker.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 25.12.24.
//

import Foundation
import SwiftUI

@MainActor
class DatePickerViewModel: ObservableObject {
    @Published var isDatePickerPressed: Bool = false
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
                        Text("Today") // add trema
                            .padding(.leading, 8)
//                            .frame(height: 32)
                        
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
                    print("pressed right button")
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
                                     onDaySelected: {
                            viewModel.isDatePickerPressed.toggle()
                        },
                                     viewModelClosure: CalendarViewModel(appState: self.appState,
                                                                         appDataSource: self.appDataSource))
                        
                        Spacer()
                    }
                }
                .task {
                    await appDataSource.fetchMonthlyDayData(selectedMonth: calendar.component(.month, from: appState.selectedDate), selectedYear: calendar.component(.year, from: appState.selectedDate))
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
