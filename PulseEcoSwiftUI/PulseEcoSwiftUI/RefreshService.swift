//
//  RefreshService.swift
//  PulseEcoSwiftUI
//
//  Created by Darko Skerlevski on 10.9.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class RefreshService: ObservableObject {
    let appViewModel: AppVM
    let appDataSource: DataSource
    private var refreshDate: Date = Date()
    
    init(appViewModel: AppVM, appDataSource: DataSource) {
        self.appViewModel = appViewModel
        self.appDataSource = appDataSource
    }
    
    func refreshDataIfNeeded() {
        if let diff = Calendar.current.dateComponents([.minute], from: refreshDate, to: Date()).minute, diff >= 15 {
            refreshData()
        }
    }

    func updateRefreshDate() {
        refreshDate = Date()
    }
    
    func refreshData() {
        updateRefreshDate()
        self.appViewModel.showSensorDetails = false
        self.appViewModel.selectedSensor = nil
        self.appViewModel.updateMapAnnotations = true
        self.appViewModel.updateMapRegion = true
        self.appDataSource.loadingMeasures = true
        self.appDataSource.getMeasures()
        self.appDataSource.loadingCityData = true
        self.appDataSource.getValuesForCity(cityName: self.appViewModel.cityName)
    }
    
}
