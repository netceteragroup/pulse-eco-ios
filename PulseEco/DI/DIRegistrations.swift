//
//  ResolverRegistry.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 4.11.25.
//


import Factory

extension Container {
    var locationService: Factory<any LocationService> {
        Factory(self) { LocationServiceImpl() }
    }
    
    var appDataManager: Factory<any AppDataManagerProtocol> {
        Factory(self) { MainActor.assumeIsolated { AppDataManager(appData: AppData()) }}.singleton
    }
    
    @MainActor
    var refreshService: Factory<any RefreshServiceProtocol> {
        let appData = appDataManager.resolve().appData
        return Factory(self) { RefreshService(appData: appData) }.singleton
    }
    
    var networkService: Factory<any NetworkServiceProtocol> {
        Factory(self) { NetworkService() }
    }
}
