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
    @EnvironmentObject var appData: AppData
    @State var selectedDate: Date

    @Injected(\.appDataManager) private var appDataManager
    
    @State private var isDatePickerPressed: Bool = false

    var body: some View {
        VStack {
            DateSlider(unimplementedPicker: $isDatePickerPressed,
                       selectedDate: $selectedDate)
            if isDatePickerPressed {
                CalendarView(showingCalendar: $isDatePickerPressed,
                             selectedDate: $selectedDate,
                             viewModelClosure: CalendarViewModel(appData: self.appData))
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: appData.selectedMeasureId) { _, _ in
                    isDatePickerPressed = false
                }
            }
        }
    }
}

#Preview {
    VStack {
        DateSelector(selectedDate: AppData().selectedDate)
            .padding(.horizontal)
            .padding(.vertical, 8)
        
        Spacer()
    }
}
