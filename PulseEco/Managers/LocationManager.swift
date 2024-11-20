//
//  LocationManager.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 11.11.24.
//

import Foundation
import CoreLocation

enum LocationAthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
    case unknown
    
    init(from clStatus: CLAuthorizationStatus) {
        switch clStatus {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        @unknown default:
            self = .unknown
        }
    }
}

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    static let shared = LocationManager()
    private let metersNeededToTravelToUpdateLocation: Double = 2000.0
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentCity: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.distanceFilter = metersNeededToTravelToUpdateLocation
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getAuthorizationStatus() -> LocationAthorizationStatus {
        return LocationAthorizationStatus(from: manager.authorizationStatus)
    }
    
    func reverseGeocode() {
        if let currentLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)) { [weak self] (placemarks, error) in
            
                guard let self = self else { return }
                if error != nil {
                    return
                }
                
                if let placemark = placemarks?.first {
                    self.currentCity = placemark.locality
                }
                
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
        reverseGeocode()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
        currentCity = nil
    }
}
