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
    
    func measurePressed(appState: AppState, appDataSource: AppDataSource) {
        setAsSelectedMeasure(appState: appState)
        appDataSource.selectFromSensorType()
    }
    
    private func setAsSelectedMeasure(appState: AppState) {
        appState.selectedMeasureId = id
    }
}
