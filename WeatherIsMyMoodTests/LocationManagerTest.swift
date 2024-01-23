//
//  LocationManagerTest.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 1/22/24.
//

import XCTest
import CoreLocation
import MapKit
@testable import WeatherIsMyMood
import Contacts

final class LocationManagerTest: XCTestCase {
    var locationFetcher: MockLocationFetcher!
    var locationManager: LocationManager!
    let mockCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    
    struct MockLocationFetcher: LocationFetcher {
        
        var locationFetcherDelegate: WeatherIsMyMood.LocationFetcherDelegate?
        
        var desiredAccuracy: CLLocationAccuracy = 0
        
        var distanceFilter: CLLocationDistance = 1_000_000
        
        var pausesLocationUpdatesAutomatically: Bool = false
        
        var location: CLLocation?
        
        
        func requestLocation() {
            guard let location = self.location else { return }
            locationFetcherDelegate?.locationFetcher(self, didUpdateLocations: [location])
        }
        
        func startUpdatingLocation() {
            return
        }
        
        func requestWhenInUseAuthorization() {
            return
        }
        
        static func cityName(at location: CLLocation, geocoder: WeatherIsMyMood.GeoCoder) async -> String? {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: .current)
                return placemarks.first?.locality
            } catch {
                return nil
            }
        }
        
        func location(forCity cityName: String, geocoder: WeatherIsMyMood.GeoCoder) async -> CLLocation? {
            do {
                let placemarks = try await geocoder.geocodeAddressString(cityName, in: nil)
                return placemarks.first?.location
            } catch {
                return nil
            }
        }
    }
    
    struct MockGeoCoder: GeoCoder {
        func geocodeAddressString(_ addressString: String, in region: CLRegion?) async throws -> [CLPlacemark] {
            return []
        }
        
        func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark] {
            
            // Create a mock CLPlacemark
            let mockAddressDictionary: [String: Any] = [
                CNPostalAddressCityKey: "New York"
            ]
            
            let placemark = MKPlacemark(coordinate: location.coordinate,
                                        addressDictionary: mockAddressDictionary)
            return [placemark]
            
        }
    }

    
    
    override func setUpWithError() throws {
        locationFetcher = MockLocationFetcher()
        locationManager = LocationManager(locationFetcher: locationFetcher)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_didUpdateLocations() {
        let mockLoc = CLLocation(latitude: 37.4563, longitude: 126.7052)
        self.locationManager.locationFetcher(self.locationFetcher, didUpdateLocations: [mockLoc])
        
        XCTAssertTrue(locationManager.currentLocation == mockLoc,
                      "Current Location is different. Mock location is \(mockLoc), current location is \(locationManager.currentLocation)")
        
    }
    
    func test_didFailWithError() {
        let mockError = NSError(domain: "mock_location_fail", code: 0, userInfo: nil)
        self.locationManager.locationFetcher(self.locationFetcher, didFailWithError: mockError)
        
        XCTAssertNotNil(locationManager.error)
    }

    func test_cityName() async {
        let mockGeocoder = MockGeoCoder()
        let mockLoc = CLLocation(latitude: mockCoordinate.latitude,
                                 longitude: mockCoordinate.longitude)
        
        let result = await CLLocationManager.cityName(at: mockLoc, geocoder: mockGeocoder)
        XCTAssertEqual(result!, "New York", "Location differenct: \(result)")
    }
}
