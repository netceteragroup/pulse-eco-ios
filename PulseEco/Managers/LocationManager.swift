//
//  LocationManager.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 11.11.24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    static let shared = LocationManager()
    
    @Published var currentUserLocation: CLLocationCoordinate2D?
    @Published var currentUserCity: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func isAuthorizedOrNotDetermined() -> Bool {
        let status = manager.authorizationStatus
        return status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined
    }
    
    func reverseGeocode() {
        if let currentUserLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: currentUserLocation.latitude, longitude: currentUserLocation.longitude)) { [weak self] (placemarks, error) in
            
                guard let self = self else { return }
                if error != nil {
                    return
                }
                
                if let placemark = placemarks?.first {
                    self.currentUserCity = placemark.locality
                }
                
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.first?.coordinate
        reverseGeocode()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentUserLocation = nil
        currentUserCity = nil
    }
}
