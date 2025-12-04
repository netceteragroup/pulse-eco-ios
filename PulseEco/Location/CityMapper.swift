//
//  CityMapper.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 27.11.25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class CityMapper {
    private static let logger = SystemLoggerAdapter(category: "CityMapper")
    private static let networkService = NetworkService()
    
    // Reverse geocode a coordinate to City
    static func reverseGeocode(location: CLLocationCoordinate2D) async -> City? {
        logger.logDebug("Starting reverse geocode for location: \(location.latitude), \(location.longitude)")
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: location.latitude, longitude: location.longitude)
            )
            
            guard let placemark = placemarks.first,
                  let locality = placemark.locality,
                  let country = placemark.country,
                  let countryCode = placemark.isoCountryCode
            else {
                logger.logError("Reverse geocode failed: missing placemark/locality/country/countryCode")
                return nil
            }
            
            logger.logDebug("Reverse geocoded city: \(locality), \(country)")
            
            if let city = await networkService.fetchCity(cityName: locality.lowercased()) {
                logger.logDebug("Fetched city from network: \(city.cityName)")
                return city
            } else {
                logger.logDebug("City not found in network, creating fallback City instance for \(locality)")
                return City(
                    cityName: locality.lowercased(),
                    siteName: locality,
                    siteTitle: "\(locality) @ CityPulse",
                    siteURL: "https://\(locality.lowercased()).pulse.eco",
                    countryCode: countryCode,
                    countryName: country,
                    cityLocation: CityCoordinates(
                        latitude: String(location.latitude),
                        longitute: String(location.longitude)
                    )
                )
            }
        } catch {
            logger.logError("Reverse geocode error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Fetch city region asynchronously
    static func fetchCityRegion(cityName: String) async -> MKCoordinateRegion? {
        logger.logDebug("Fetching city region for \(cityName)")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cityName
        let search = MKLocalSearch(request: request)
        
        return await withCheckedContinuation { continuation in
            search.start { response, error in
                if let error {
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let region = response?.boundingRegion else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: region)
            }
        }
    }
}
