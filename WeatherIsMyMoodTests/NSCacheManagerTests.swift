//
//  NSCacheManagerTests.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 1/27/24.
//

import XCTest
@testable import WeatherIsMyMood

final class NSCacheManagerTests: XCTestCase {

    class MockCache: NSCache<NSString, NSObject> {
        var cache: [NSString: NSObject] = [:]
        
        override func setObject(_ obj: NSObject, forKey key: NSString) {
            cache[key] = obj
        }
        override func object(forKey key: NSString) -> NSObject? {
            return cache[key]
        }
    }
    
    struct MockCacheManager: Cachable {
        var cache: NSCache<NSString, NSObject> = MockCache()
        
        func setCache(_ object: NSObject, for key: String) {
            cache.setObject(object, forKey: key as NSString)
        }
        
        func getCache(for key: String) -> NSObject? {
            cache.object(forKey: key as NSString)
        }
    }
    
    class MockClass: NSObject {
        let name: String
        
        init(name: String) {
            self.name = name
        }
    }
    
    var cacheManager: MockCacheManager!
    
    override func setUpWithError() throws {
        cacheManager = MockCacheManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_setCache() {
        let key = "key"
        let name = "A"
        let object = MockClass(name: name)
        
        cacheManager.setCache(object, for: key)
        
        let savedCache = cacheManager.cache.object(forKey: key as NSString) as? MockClass
        XCTAssertNotNil(savedCache)
        XCTAssertEqual(savedCache!.name, name)
    }

}
