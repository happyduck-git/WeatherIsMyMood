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
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1_000
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func requestOnTimeLocation() {
        currentLocation = locationManager.location
    }
    
    func refreshLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func cityName(at location: CLLocation) async -> String? {
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
