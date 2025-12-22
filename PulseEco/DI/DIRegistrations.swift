//
//  ResolverRegistry.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 4.11.25.
//


import Factory

extension Container {
    var locationService: Factory<any LocationService> {
        Factory(self) { LocationServiceImpl() }.singleton
    }
    
    var appData: Factory<any AppDataProtocol> {
        Factory(self) { AppData() }.singleton
    }
    
    var appDataManager: Factory<any AppDataManagerProtocol> {
        Factory(self) { AppDataManager() }.singleton
    }
    
    var refreshService: Factory<any RefreshServiceProtocol> {
        Factory(self) { RefreshService() }.singleton
    }
}
