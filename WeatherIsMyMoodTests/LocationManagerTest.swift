//
//  LocationManagerTest.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 1/22/24.
//

import XCTest
import CoreLocation
@testable import WeatherIsMyMood

final class LocationManagerTest: XCTestCase {

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
    }
    
    var locationFetcher: MockLocationFetcher!
    var locationManager: LocationManager!
    
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

}
