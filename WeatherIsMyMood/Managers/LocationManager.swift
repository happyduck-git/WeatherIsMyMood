//
//  LocationManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import Foundation
import CoreLocation

protocol LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var distanceFilter: CLLocationDistance { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var location: CLLocation? { get }
    func requestLocation()
    func startUpdatingLocation()
    func requestWhenInUseAuthorization()
}

protocol LocationFetcherDelegate: AnyObject {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation])
}

final class LocationManager: NSObject, ObservableObject {

    @Published var currentLocation: CLLocation?
    @Published var previousLocation: CLLocation?
    
    @Published var cityName: String?
    static var locationManager: LocationFetcher = CLLocationManager()
    
    override init() {
        super.init()
        LocationManager.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        LocationManager.locationManager.distanceFilter = 1_000
        LocationManager.locationManager.pausesLocationUpdatesAutomatically = true
        LocationManager.locationManager.requestWhenInUseAuthorization()
        LocationManager.locationManager.startUpdatingLocation()
        LocationManager.locationManager.locationFetcherDelegate = self
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
        self.locationFetcher(manager, didUpdateLocations: locations)
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        print("Location didFailWithError -- \(error)")
        #endif
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

extension LocationManager: LocationFetcherDelegate {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
    }
}

extension CLLocationManager: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}
