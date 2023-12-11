//
//  LocationManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    
    @Published var currentLocation: CLLocation? {
        //TODO: 안 사용하면 didSet 지우기
        didSet {
            guard let loc = currentLocation else { return }
            self.cityName(at: loc) { city in
                self.cityName = city
            }
        }
    }
    @Published var cityName: String?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func requestOnTimeLocation() {
        currentLocation = locationManager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func cityName(at location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Reverse geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                completion(nil)
                return
            }

            let cityName = placemark.locality
            completion(cityName)
        }
    }
    
    func location(forCity cityName: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(cityName) { placemarks, error in
            guard error == nil else {
                print("Geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No location found for \(cityName)")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}
