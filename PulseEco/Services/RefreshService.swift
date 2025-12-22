//
//  RefreshService.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 10.9.21.
//

import Foundation
import SwiftUI
import Factory

protocol RefreshServiceProtocol {
    func refreshDataIfNeeded()
    func updateRefreshDate()
    func refreshData()
}

class RefreshService: ObservableObject, RefreshServiceProtocol {
    
    @Injected(\.appData) private var appData
    @Injected(\.appDataManager) private var appDataManager
    private var refreshDate: Date = Date()
    
    func refreshDataIfNeeded() {
        if let diff = calendar.dateComponents([.minute], from: refreshDate, to: Date()).minute, diff >= 15 {
            self.appData.selectedSensor = nil
            self.refreshData()
        }
    }

    func updateRefreshDate() {
        refreshDate = Date()
        appData.selectedDate = calendar.startOfDay(for: Date.now)
        appData.showingCalendar = false
        appData.selectedMeasureId = "pm10"
    }
    
    func refreshData() {
        updateRefreshDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.appData.selectedSensor = nil
            self.appData.loadingMeasures = true
            self.appDataManager.getMeasures()
            self.appDataManager.fetchData(cityName: UserSettings.selectedCity.cityName, sensorType: self.appData.selectedMeasureId, selectedDate: self.appData.selectedDate)
        }
    }
    
}
