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
    static func cityName(at location: CLLocation, geocoder: GeoCoder) async -> String?
    func location(forCity cityName: String, geocoder: GeoCoder) async -> CLLocation?
}

protocol LocationFetcherDelegate: AnyObject {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation])
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error)
}

protocol GeoCoder {
    func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark]
    func geocodeAddressString(_ addressString: String, in region: CLRegion?) async throws -> [CLPlacemark]
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

extension LocationManager {
    func requestOnTimeLocation() {
        currentLocation = self.locationFetcher.location
    }
    
    func refreshLocation() {
        self.locationFetcher.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated: \(locations.map({ $0.coordinate.latitude }))")
        self.locationFetcher(manager, didUpdateLocations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        Logger().error("Location didFailWithError -- \(error)")
        #endif
        self.locationFetcher(manager, didFailWithError: error)
    }

}

extension LocationManager: LocationFetcherDelegate {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
//        print("Current Loction value: \(self.currentLocation?.coordinate.latitude)")
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error) {
        self.error = error
    }
    
}

extension CLLocationManager: LocationFetcher {
    static func cityName(at location: CLLocation, geocoder: GeoCoder = CLGeocoder()) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: .current)
            return placemarks.first?.locality
        } catch {
            print("Reverse geocoding error: \(error)")
            return nil
        }
    }
    
    func location(forCity cityName: String, geocoder: GeoCoder = CLGeocoder()) async -> CLLocation? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName, in: nil)
            return placemarks.first?.location
        } catch {
            print("Geocoding error: \(error)")
            return nil
        }
    }
    
    
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}

extension CLGeocoder: GeoCoder {}
