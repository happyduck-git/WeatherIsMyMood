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
    func locationFetcher(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}

protocol GeoCoder {
    func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark]
    func geocodeAddressString(_ addressString: String, in region: CLRegion?) async throws -> [CLPlacemark]
}

final class LocationManager: NSObject, ObservableObject {

    @Published var currentLocation: CLLocation?
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
    func requestOnTimeLocation() async {
        currentLocation = self.locationFetcher.location
        guard let currentLocation else {
            return
        }
        self.cityName = await self.cityName(at: currentLocation)
    }
    
    func refreshLocation() {
        self.locationFetcher.startUpdatingLocation()
    }
    
    func cityName(at location: CLLocation, geocoder: GeoCoder = CLGeocoder()) async -> String? {
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
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated... LAT: \(locations.map({ $0.coordinate.latitude })), LON: \(locations.map({ $0.coordinate.longitude }))")
        self.locationFetcher(manager, didUpdateLocations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        Logger().error("Location didFailWithError -- \(error)")
        #endif
        self.locationFetcher(manager, didFailWithError: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationFetcher(manager, didChangeAuthorization: status)
    }

}

extension LocationManager: LocationFetcherDelegate {
    func locationFetcher(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            self.error = LocationError.notAuthorized
        default:
            self.error = nil
        }
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    
}

extension CLLocationManager: LocationFetcher {

    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}

extension CLGeocoder: GeoCoder {}

enum LocationError: Error {
    case notAuthorized
}

