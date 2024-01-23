//
//  LocationManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import Foundation
import CoreLocation
import OSLog

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
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error)
}

final class LocationManager: NSObject, ObservableObject {

    @Published var currentLocation: CLLocation?
    @Published var previousLocation: CLLocation?
    @Published var cityName: String?
    @Published var error: Error?
    
    var locationFetcher: LocationFetcher
    
    init(locationFetcher: LocationFetcher) {
        self.locationFetcher = locationFetcher
        super.init()
        self.locationFetcher.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationFetcher.distanceFilter = 1_000
        self.locationFetcher.pausesLocationUpdatesAutomatically = true
        self.locationFetcher.requestWhenInUseAuthorization()
        self.locationFetcher.startUpdatingLocation()
        self.locationFetcher.locationFetcherDelegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func requestOnTimeLocation() {
        currentLocation = self.locationFetcher.location
    }
    
    func refreshLocation() {
        self.locationFetcher.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationFetcher(manager, didUpdateLocations: locations)
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        Logger().error("Location didFailWithError -- \(error)")
        #endif
        self.locationFetcher(manager, didFailWithError: error)
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
    
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error) {
        self.error = error
    }
    
}

extension CLLocationManager: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}
