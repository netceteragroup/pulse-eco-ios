//
//  LocationServiceImpl.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 17.10.25.
//

import CoreLocation
import Foundation
import Combine

final class LocationServiceImpl: NSObject, LocationService {
    private let locationManager = CLLocationManager()
    private let logger = SystemLoggerAdapter(category: "LocationService")

    // MARK: - Observables
    private let location = MutableStateObservable<City>(initialValue: .defaultCity())
    private let authorizationStatus = MutableStateObservable<AuthorizationStatus>(initialValue: .notDetermined)
    
    private var isUpdatingLocation = false

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .otherNavigation
        locationManager.delegate = self

        handleAuthorizationStatus(locationManager.authorizationStatus)
    }

    // MARK: - LocationService conformance

    var lastLocation: City? {
        guard authorizationStatus.value == .authorized else { return nil }
        return location.value
    }

    func locationObserver() -> any StateObservable<City> {
        startLocationUpdatesIfNeeded()
        return location
    }

    func authorizationStatusObserver() -> any StateObservable<AuthorizationStatus> {
        authorizationStatus
    }

    func currentAuthorizationStatus() -> AuthorizationStatus {
        mapAuthorizationStatus(locationManager.authorizationStatus)
    }

    // MARK: - Private helpers

    private func startLocationUpdatesIfNeeded() {
        guard !isUpdatingLocation, authorizationStatus.value == .authorized else { return }
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }

    private func stopLocationUpdates() {
        guard isUpdatingLocation else { return }
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    private func askPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        case .authorizedAlways, .authorizedWhenInUse: return .authorized
        @unknown default: return .notDetermined
        }
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        let mappedStatus = mapAuthorizationStatus(status)
        authorizationStatus.setNewValue(mappedStatus)

        switch mappedStatus {
        case .notDetermined:
            askPermission()
        case .authorized:
            startLocationUpdatesIfNeeded()
        case .denied:
            stopLocationUpdates()
            location.setNewValue(.defaultCity())
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationServiceImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            if let newCity = await CityMapper.reverseGeocode(location: location.coordinate) {
                // Check if city actually changed
                let oldCityName = self.location.value.cityName.lowercased()
                let newCityName = newCity.cityName.lowercased()

                if oldCityName != newCityName {
                    logger.logDebug("New city detected: \(newCity.cityName)")
                    self.location.setNewValue(newCity)
                } else {
                    // same city – no need to notify observers
                    logger.logDebug("Location updated within same city (\(newCityName)), skipping update.")
                }
            } else {
                logger.logError("Failed to reverse geocode location")
                self.location.setNewValue(.defaultCity())
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.logError("Location manager failed: \(error.localizedDescription)")
        location.setNewValue(.defaultCity())
    }
}
