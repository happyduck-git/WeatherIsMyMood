//
//  NSCacheManagerTests.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 1/27/24.
//

import XCTest
@testable import WeatherIsMyMood

final class NSCacheManagerTests: XCTestCase {
    class MockClass: NSObject {
        let name: String
        
        init(name: String) {
            self.name = name
        }
    }
    
    var cacheManager: NSCacheManager!
    
    override func setUpWithError() throws {
        cacheManager = NSCacheManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_setCache() {
        let key = "key"
        let name = "A"
        let object = MockClass(name: name)
        
        cacheManager.setCache(object, for: key)
        
        let savedCache = cacheManager.getCache(for: key) as? MockClass
        XCTAssertNotNil(savedCache)
        XCTAssertEqual(savedCache!.name, name)
    }

}
