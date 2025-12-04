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
    @StateObject private var appState: AppState
    @StateObject private var dataSource: AppDataSource
    @StateObject private var refreshService: RefreshService
    @StateObject private var mapViewModel: MapViewModel

    // MARK: - Initialization
    init() {
        // 1. Initialize app state and data sources
        let state = AppState()
        let ds = AppDataSource(appState: state)
        let mapVM = MapViewModel(appState: state, appDataSource: ds)
        let refreshSvc = RefreshService(appViewModel: state, appDataSource: ds)
        
        // 2. Assign to @StateObjects
        _appState = StateObject(wrappedValue: state)
        _dataSource = StateObject(wrappedValue: ds)
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _refreshService = StateObject(wrappedValue: refreshSvc)
        
        // 3. Customize UITableView appearance globally (optional)
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            MainView(mapViewModel: mapViewModel)
                .environmentObject(appState)
                .environmentObject(dataSource)
                .environmentObject(refreshService)
                .onAppear {
                    refreshService.refreshDataIfNeeded()
                }
        }
    }
}
