//
//  AuthorizationStatus.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 17.10.25.
//

import Foundation
import Combine

enum AuthorizationStatus {
    case notDetermined
    case denied
    case authorized
}

protocol LocationService {
    /// Observer for location changes
    func locationObserver() -> any StateObservable<City>
    
    /// Last location obtained by the service
    var lastLocation: City? { get }
    
    /// Observer for authorization status changes
    func authorizationStatusObserver() -> any StateObservable<AuthorizationStatus>
    
    /// Get the current authorization status
    func currentAuthorizationStatus() -> AuthorizationStatus
}
