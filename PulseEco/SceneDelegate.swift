//
//  SceneDelegate.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 5/28/20.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    private (set) var refreshService: RefreshService!
    
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new
    // (see `application:configurationForConnectingSceneSession` instead).
    // Create the SwiftUI view that provides the window contents.
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        let appState = AppState()
        let dataSource = AppDataSource(appState: appState)
        
        let mapViewModel = MapViewModel(appState: appState, appDataSource: dataSource)
        self.refreshService = RefreshService(appViewModel: appState, appDataSource: dataSource)
        let rootView = MainView(mapViewModel: mapViewModel)
        UITableView.appearance().separatorColor = .clear
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView
                                                                .environmentObject(dataSource)
                                                                .environmentObject(appState)
                                                                .environmentObject(refreshService))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        refreshService.refreshDataIfNeeded()
    }
}
