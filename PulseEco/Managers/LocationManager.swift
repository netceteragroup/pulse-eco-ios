//
//  LocationManager.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 11.11.24.
//

import Foundation
import CoreLocation
import MapKit
import Combine

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
    let logger: SystemLoggerAdapter = SystemLoggerAdapter(category: "locationManager")
    
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
    @Published var isWaitingToFetchRegion: Bool = true
    
    var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.distanceFilter = metersNeededToTravelToUpdateLocation
        manager.startUpdatingLocation()
        
        regionSubscriber()
    }
    
    func regionSubscriber() {
        $region
            .dropFirst()
            .sink { [weak self] _ in
            guard let self else { return }
            self.isWaitingToFetchRegion = false
        }
        .store(in: &cancellables)
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getAuthorizationStatus() -> LocationAthorizationStatus {
        return LocationAthorizationStatus(from: manager.authorizationStatus)
    }
    
    func isAuthorizationGranted() -> Bool {
        return (getAuthorizationStatus() == .authorizedAlways || getAuthorizationStatus() == .authorizedWhenInUse)
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
                logger.logError("could not get one of the following: placemark, locality, country or countryCode")
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
            self.logger.logError("reverseGeocode returned an error: \(String(describing: error))")
            return nil
        }
    }
    
    func fetchCityRegion(cityName: String?) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cityName
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let _ = response?.mapItems.first, error == nil else {
                self.logger.logError("MKLocalSearch returned an error: \(String(describing: error))")
                return
            }
            
            if let region = response?.boundingRegion {
                DispatchQueue.main.async {
                    self.region = region
                }
            }
            else {
                self.logger.logError("region could not be calculated")
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
