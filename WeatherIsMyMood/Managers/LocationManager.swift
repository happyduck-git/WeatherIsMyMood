//
//  LocationManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    
    @Published var currentLocation: CLLocation?
    @Published var previousLocation: CLLocation?
    
    @Published var cityName: String?
    static let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        LocationManager.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        LocationManager.locationManager.distanceFilter = 1_000
        LocationManager.locationManager.pausesLocationUpdatesAutomatically = true
        LocationManager.locationManager.requestWhenInUseAuthorization()
        LocationManager.locationManager.startUpdatingLocation()
        LocationManager.locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func requestOnTimeLocation() {
        currentLocation = LocationManager.locationManager.location
    }
    
    func refreshLocation() {
        LocationManager.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    static func cityName(at location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: .current)
            return placemarks.first?.locality
        } catch {
            print("Reverse geocoding error: \(error)")
            return nil
        }
    }

    func location(forCity cityName: String) async -> CLLocation? {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            return placemarks.first?.location
        } catch {
            print("Geocoding error: \(error)")
            return nil
        }
    }
    
}
