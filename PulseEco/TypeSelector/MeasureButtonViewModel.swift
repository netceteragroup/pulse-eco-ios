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
        setAsSelectedMeasure(appState: appState)
        await appDataSource.updatePins(selectedDate: appState.selectedDate)
        await appDataSource.setAverageValueforSelectedDate(cityName: appState.selectedCity.cityName, sensorType: id, selectedDate: appState.selectedDate)
    }
    
    private func setAsSelectedMeasure(appState: AppState) {
        appState.selectedMeasureId = id
        appState.showSensorDetails = false
    }
}
