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
    var mockGeocoder: GeoCoder!
    let mockCity: String = "New York"
    let mockCoordinate = CLLocation(latitude: 40.7128, longitude: -74.0060)
    
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
        let mockCity: String = "New York"
        let mockLoc = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        func geocodeAddressString(_ addressString: String, in region: CLRegion?) async throws -> [CLPlacemark] {
            guard let loc = self.convertAddressToLocation(addressString) else {
                return []
            }
            let mockAddressDictionary: [String: Any] = [
                CNPostalAddressCityKey: mockCity
            ]
            
            let placemark = MKPlacemark(coordinate: loc.coordinate,
                                        addressDictionary: mockAddressDictionary)
            return [placemark]
        }
        
        func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark] {
            
            // Create a mock CLPlacemark
            let mockAddressDictionary: [String: Any] = [
                CNPostalAddressCityKey: mockCity
            ]
            
            let placemark = MKPlacemark(coordinate: location.coordinate,
                                        addressDictionary: mockAddressDictionary)
            return [placemark]
            
        }
        
        private func convertAddressToLocation(_ addressString: String) -> CLLocation? {
            if addressString == mockCity {
                return mockLoc
            }
            return nil
        }
    }

    override func setUpWithError() throws {
        locationFetcher = MockLocationFetcher()
        locationManager = LocationManager(locationFetcher: locationFetcher)
        mockGeocoder = MockGeoCoder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_didUpdateLocations() {
        let mockLoc = CLLocation(latitude: 37.4563, longitude: 126.7052)
        self.locationManager.locationFetcher(self.locationFetcher, didUpdateLocations: [mockLoc])
        
        XCTAssertTrue(locationManager.currentLocation == mockLoc,
                      "Current Location is different. Mock location is \(mockLoc), current location is \(String(describing: locationManager.currentLocation))")
        
    }
    
    func test_didFailWithError() {
        let mockError = NSError(domain: "mock_location_fail", code: 0, userInfo: nil)
        self.locationManager.locationFetcher(self.locationFetcher, didFailWithError: mockError)
        
        XCTAssertNotNil(locationManager.error)
    }

    func test_cityName() async {
        let result = await self.locationManager.cityName(at: self.mockCoordinate, geocoder: mockGeocoder)
        XCTAssertEqual(result!, "New York", "Location differenct: \(String(describing: result))")
    }
    
    func test_location() async {
        let result = await self.locationManager.location(forCity: self.mockCity, geocoder: mockGeocoder)
        XCTAssertEqual(result!.altitude, self.mockCoordinate.altitude)
    }
}
