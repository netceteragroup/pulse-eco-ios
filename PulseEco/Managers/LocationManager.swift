//
//  LocationManager.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 11.11.24.
//

import Foundation
import CoreLocation
import MapKit

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
    
    var didSetCurrentCity: ((City?) -> Void)?
    let networkService: NetworkService = NetworkService()
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentCity: City? {
        didSet {
            guard currentCity != oldValue
            else {
                return
            }
            didSetCurrentCity?(currentCity)
        }
    }
    @Published var region: MKCoordinateRegion?
    
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
    
    func isAuthorizationGrantedAndWaitingToFetchRegion() -> Bool {
        return (getAuthorizationStatus() == .authorizedAlways || getAuthorizationStatus() == .authorizedWhenInUse) && region == nil
    }
    
    func reverseGeocode(location: CLLocationCoordinate2D) async -> City?  {
        let geocoder = CLGeocoder()
        do {
            let geocoderResult = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude,
                                                                                       longitude: location.longitude))
            guard let placemark = geocoderResult.first,
                  let locality = placemark.locality,
                  let country = placemark.country,
                  let countryCode = placemark.isoCountryCode
            else {
                return nil
            }
            
            guard let city = await networkService.fetchCity(cityName: locality.lowercased()) else {
                return  City(cityName: locality.lowercased(),
                             siteName: locality,
                             siteTitle: locality + " @ CityPulse",
                             siteURL: "https://" + locality.lowercased() + ".pulse.eco",
                             countryCode: countryCode,
                             countryName: country,
                             cityLocation: CityCoordinates(latitude: String(location.latitude), longitute: String(location.longitude))
                             )
            }
            return city
        }
        catch let error {
            return nil
        }
    }
    
    func fetchCityRegion(cityName: String?) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cityName
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let mapItem = response?.mapItems.first, error == nil else {
                return
            }
            
            if let region = response?.boundingRegion {
                self.region = region
            }
            else {
                return
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newCoordinate = locations.first?.coordinate
        else {
            return
        }
        
        Task {
            let currentCityReverseGeocoded = await reverseGeocode(location: newCoordinate)
            DispatchQueue.main.async { [weak self] in
                guard let self
                else {
                    return
                }
                self.currentLocation = newCoordinate
                self.currentCity = currentCityReverseGeocoded
                fetchCityRegion(cityName: currentCity?.cityName)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
        currentCity = nil
    }
}
