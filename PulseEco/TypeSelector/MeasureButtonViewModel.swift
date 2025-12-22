import Foundation
import SwiftUI
import Factory

@MainActor
class MeasureButtonViewModel: ObservableObject {
    @Injected(\.appData) private var appData: AppDataProtocol
    @Injected(\.appDataManager) private var appDataManager
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
    
    func measurePressed() {
        appData.selectedMeasureId = id
        appDataManager.selectFromSensorType()
    }
}
