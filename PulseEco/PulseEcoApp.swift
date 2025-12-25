//
//  PulseEcoApp.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 4.11.25.
//

import SwiftUI
import Factory

@main
struct PulseEcoApp: App {
    
    // MARK: - State Objects
    @StateObject private var appData: AppData
    @StateObject private var cityMapViewModel: CityMapViewModel
    @Injected(\.appDataManager) private var appDataManager

    // MARK: - Initialization
    init() {
        // 1. Initialize app state and data sources
        let appDataManager = Container.shared.appDataManager.resolve()
        let appData = appDataManager.appData
        let cityMapViewModel = CityMapViewModel()
        
        // 2. Assign to @StateObjects
        _appData = StateObject(wrappedValue: appData)
        _cityMapViewModel = StateObject(wrappedValue: cityMapViewModel)
        
        // 3. Customize UITableView appearance globally (optional)
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            MainView(cityMapViewModel: cityMapViewModel)
                .environmentObject(appData)
        }
    }
}
