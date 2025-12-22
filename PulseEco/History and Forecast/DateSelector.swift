//
//  DateSelector.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 25.12.24.
//

import Foundation
import SwiftUI
import Combine
import Factory

struct DateSelector: View {
    @StateObject private var viewModel = DateSelectorViewModel()
    @Injected(\.appData) private var appData
    @Injected(\.appDataManager) private var appDataManager

    @Binding private var showingCalendar: Bool
    @Binding private var selectedDate: Date
    
    init(showingCalendar: Binding<Bool>, selectedDate: Binding<Date>) {
        self._showingCalendar = showingCalendar
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        VStack {
            DateSlider(unimplementedAlert: $showingCalendar,
                       unimplementedPicker: $viewModel.isDatePickerPressed,
                       selectedDate: $selectedDate)
            if viewModel.isDatePickerPressed {
                CalendarView(showingCalendar: $viewModel.isDatePickerPressed,
                             selectedDate: $selectedDate,
                             onDaySelected: { newDate in viewModel.selectedDate = newDate },
                             viewModelClosure: CalendarViewModel())
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: appData.selectedMeasureId) { _, newValue in
                    viewModel.isDatePickerPressed = false
                    viewModel.onSelectedMeasureChange?.cancel()
                    viewModel.onSelectedMeasureChange = Task {
                        await appDataManager.fetchMonthlyDayData(selectedMonth: calendar.component(.month, from: viewModel.selectedDate), selectedYear: calendar.component(.year, from: viewModel.selectedDate))
                    }
                }
            }
        }
    }
}
