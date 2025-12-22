//
//  PulseEcoApp.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 4.11.25.
//

import SwiftUI

@main
struct PulseEcoApp: App {
    
    // MARK: - State Objects
    @StateObject private var appData: AppData
    @StateObject private var appDataManager: AppDataManager
    @StateObject private var refreshService: RefreshService
    @StateObject private var mapViewModel: MapViewModel

    // MARK: - Initialization
    init() {
        // 1. Initialize app state and data sources
        let appData = AppData()
        let appDataManager = AppDataManager(appData: appData)
        let mapVM = MapViewModel(appDataManager: appDataManager)
        let refreshSvc = RefreshService(appViewModel: appData, appDataManager: appDataManager)
        
        // 2. Assign to @StateObjects
        _appData = StateObject(wrappedValue: appData)
        _appDataManager = StateObject(wrappedValue: appDataManager)
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _refreshService = StateObject(wrappedValue: refreshSvc)
        
        // 3. Customize UITableView appearance globally (optional)
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            MainView(mapViewModel: mapViewModel)
                .environmentObject(appData)
                .environmentObject(appDataManager)
                .environmentObject(refreshService)
                .onAppear {
                    appDataManager.startInitialFetch()
                    refreshService.refreshDataIfNeeded()
                }
        }
    }
}
