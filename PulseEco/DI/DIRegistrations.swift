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
}
