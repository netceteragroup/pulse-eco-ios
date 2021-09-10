//
//  SceneDelegate.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 5/28/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    private (set) var refreshService: RefreshService!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        //let contentView = ContentView()
          
             //.environmentObject(sheetManager)
        let appViewModel = AppVM()
        let dataSource = DataSource()
        self.refreshService = RefreshService(appViewModel: appViewModel, appDataSource: dataSource)
        let rootView = MainView(refreshService: refreshService)
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView
                                                                .environmentObject(appViewModel)
                                                                .environmentObject(dataSource))
            self.window = window
            window.makeKeyAndVisible()
        }
    
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        refreshService.refreshDataIfNeeded()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

class RefreshService {
    let appViewModel: AppVM
    let appDataSource: DataSource
    private var refreshDate: Date = Date()
    
    init(appViewModel: AppVM, appDataSource: DataSource) {
        self.appViewModel = appViewModel
        self.appDataSource = appDataSource
    }
    
    func refreshDataIfNeeded() {
        if let diff = Calendar.current.dateComponents([.second], from: refreshDate, to: Date()).second, diff > 5 {
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
