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

class RefreshService: RefreshServiceProtocol {
    
    let appData: AppData
    @Injected(\.appDataManager) private var appDataManager
    private var refreshDate: Date = Date()
    
    init(appData: AppData) {
        self.appData = appData
    }
    
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
        appData.selectedHour = calendar.component(.hour, from: Date.now)
        appData.selectedSensorsForGraph.removeAll()
        appData.selectedSensor = nil
    }
    
    func refreshData() {
        updateRefreshDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.appData.selectedSensor = nil
            self.appData.loadingMeasures = true
            self.appDataManager.getMeasures()
            self.appDataManager.fetchData()
        }
    }
}
