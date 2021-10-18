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
        let appViewModel = AppState()
        let dataSource = AppDataSource()
        let mapViewModel = MapViewModel(appState: appViewModel,
                                        appDataSource: dataSource)
        self.refreshService = RefreshService(appViewModel: appViewModel, appDataSource: dataSource)
        let rootView = MainView(mapViewModel: mapViewModel)
        UITableView.appearance().separatorColor = .clear
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView
                                                                .environmentObject(appViewModel)
                                                                .environmentObject(dataSource)
                                                                .environmentObject(refreshService))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        refreshService.refreshDataIfNeeded()
    }
    
}
