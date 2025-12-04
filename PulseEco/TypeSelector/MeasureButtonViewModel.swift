import Foundation
import SwiftUI

@MainActor
class MeasureButtonViewModel: ObservableObject {
    var id: String
    var title: String
    var selectedMeasure: String
    var underlineColor: Color { return selectedMeasure == id ? Color(AppColors.purple) : Color.clear }
    var clickDisabled: Bool = false
    var icon: String
    var titleColor: Color {
        return clickDisabled ? AppColors.gray.color : AppColors.black.color
    }
    
    init(id: String, title: String, selectedMeasure: String, icon: String) {
        self.id = id
        self.title = title
        self.selectedMeasure = selectedMeasure
        self.icon = icon
    }
    
    func measurePressed(appState: AppState, appDataSource: AppDataSource) async {
        await appDataSource.updateWeeklyDataWrapper(cityName: appState.selectedCity.cityName, measureId: id, selectedDate: appState.calendarSelection)
        appState.selectedMeasureId = id
        await appDataSource.fetchHistory(for: UserSettings.selectedCity.cityName, measureId: id)
        appState.selectedDateAverageValue = appState.weeklyDataWrapper.getDataFromRange(cityName: appState.selectedCity.cityName,
                                                                                        sensorType: id,
                                                                                        from: appState.selectedDate,
                                                                                        to: calendar.date(byAdding: .day,
                                                                                                          value: +1,
                                                                                                          to: appState.selectedDate)!).first?.value
        await appDataSource.updatePins(selectedDate: appState.selectedDate)
        await appDataSource.setAverageValueForSelectedDate(cityName: appState.selectedCity.cityName, sensorType: id, selectedDate: appState.selectedDate)
    }
}
