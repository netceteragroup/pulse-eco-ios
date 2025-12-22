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
    @StateObject private var mapViewModel: MapViewModel

    // MARK: - Initialization
    init() {
        // 1. Initialize app state and data sources
        let mapVM = MapViewModel()
        
        // 2. Assign to @StateObjects
        _mapViewModel = StateObject(wrappedValue: mapVM)
        
        // 3. Customize UITableView appearance globally (optional)
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            MainView(mapViewModel: mapViewModel)
        }
    }
}
