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
    @EnvironmentObject var appData: AppData
    @Injected(\.appDataManager) private var appDataManager

    var body: some View {
        VStack {
            DateSlider(unimplementedAlert: $appData.showingCalendar,
                       unimplementedPicker: $viewModel.isDatePickerPressed,
                       selectedDate: $appData.selectedDate)
            if viewModel.isDatePickerPressed {
                CalendarView(showingCalendar: $viewModel.isDatePickerPressed,
                             selectedDate: $appData.selectedDate,
                             onDaySelected: { newDate in viewModel.selectedDate = newDate },
                             viewModelClosure: CalendarViewModel(appData: self.appData))
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

#Preview {
    VStack {
        DateSelector()
            .padding(.horizontal)
            .padding(.vertical, 8)
        
        Spacer()
    }
}
