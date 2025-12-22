//
//  RefreshService.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 10.9.21.
//

import Foundation
import SwiftUI

class RefreshService: ObservableObject {
    
    let appViewModel: AppData
    let appDataManager: AppDataManager
    private var refreshDate: Date = Date()
    
    init(appViewModel: AppData, appDataManager: AppDataManager) {
        self.appViewModel = appViewModel
        self.appDataManager = appDataManager
    }
    
    func refreshDataIfNeeded() {
        if let diff = calendar.dateComponents([.minute], from: refreshDate, to: Date()).minute, diff >= 15 {
            self.appViewModel.selectedSensor = nil
            self.refreshData()
        }
    }

    func updateRefreshDate() {
        refreshDate = Date()
        appViewModel.selectedDate = calendar.startOfDay(for: Date.now)
        appViewModel.showingCalendar = false
        appViewModel.selectedMeasureId = "pm10"
    }
    
    func refreshData() {
        updateRefreshDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.appViewModel.selectedSensor = nil
            self.appViewModel.loadingMeasures = true
            self.appDataManager.getMeasures()
            self.appDataManager.fetchData(cityName: UserSettings.selectedCity.cityName, sensorType: self.appViewModel.selectedMeasureId, selectedDate: self.appViewModel.selectedDate)
        }
    }
    
}
