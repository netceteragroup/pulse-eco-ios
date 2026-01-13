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
    /// Publisher that is sent when the location changes.
    var onLocationChangeSubject: PassthroughSubject<City, Never> { get }
    
    /// Last location obtained by the service
    var lastLocation: City? { get }
    
    /// Observer for authorization status changes
    func authorizationStatusObserver() -> AnyPublisher<AuthorizationStatus, Never>
    
    /// Get the current authorization status
    func currentAuthorizationStatus() -> AuthorizationStatus
}
