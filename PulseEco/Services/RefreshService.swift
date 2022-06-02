//
//  RefreshService.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 10.9.21.
//

import Foundation
import SwiftUI

class RefreshService: ObservableObject {
    
    let appViewModel: AppState
    let appDataSource: AppDataSource
    private var refreshDate: Date = Date()
    
    init(appViewModel: AppState, appDataSource: AppDataSource) {
        self.appViewModel = appViewModel
        self.appDataSource = appDataSource
    }
    
    func refreshDataIfNeeded() {
        if let diff = Calendar.current.dateComponents([.minute], from: refreshDate, to: Date()).minute, diff >= 15 {
            self.appViewModel.selectedSensor = nil
            self.refreshData()
        }
    }

    func updateRefreshDate() {
        refreshDate = Date()
        appDataSource.selectedDate = Calendar.current.startOfDay(for: Date.now)
        appDataSource.showingCalendar = false
        appViewModel.selectedMeasureId = "pm10"
    }
    
    func refreshData() {
        updateRefreshDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.appViewModel.showSensorDetails = false
            self.appViewModel.selectedSensor = nil
            self.appDataSource.loadingMeasures = true
            self.appDataSource.getMeasures()
            self.appDataSource.getValuesForCity(cityName: self.appViewModel.selectedCity.cityName)
        }
    }
    
}
