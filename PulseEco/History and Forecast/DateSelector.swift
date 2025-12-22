//
//  DateSelector.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 25.12.24.
//

import Foundation
import SwiftUI
import Combine

struct DateSelector: View {
    @StateObject private var viewModel = DateSelectorViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appDataSource: AppDataSource
    
    var body: some View {
        VStack {
            DateSlider(unimplementedAlert: $appState.showingCalendar,
                       unimplementedPicker: $viewModel.isDatePickerPressed,
                       selectedDate: $appState.selectedDate)
            if viewModel.isDatePickerPressed {
                CalendarView(showingCalendar: $viewModel.isDatePickerPressed,
                             selectedDate: $appState.selectedDate,
                             onDaySelected: { newDate in viewModel.selectedDate = newDate },
                             viewModelClosure: CalendarViewModel(appState: self.appState,
                                                                 appDataSource: self.appDataSource))
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: appState.selectedMeasureId) { _, newValue in
                    viewModel.isDatePickerPressed = false
                    viewModel.onSelectedMeasureChange?.cancel()
                    viewModel.onSelectedMeasureChange = Task {
                        await appDataSource.fetchMonthlyDayData(selectedMonth: calendar.component(.month, from: viewModel.selectedDate), selectedYear: calendar.component(.year, from: viewModel.selectedDate))
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        DateSelector()
            .padding(.horizontal)
            .padding(.vertical, 8)
        
        Spacer()
    }
}
