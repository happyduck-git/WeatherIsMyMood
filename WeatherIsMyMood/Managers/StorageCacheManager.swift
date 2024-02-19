//
//  StorageCacheManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

final class StorageCacheManager: Cachable {

    var cache: NSCache<NSString, NSData> = NSCache<NSString, NSData>()
    
    static let shared = StorageCacheManager()
    private init() {}
}

extension StorageCacheManager {
    //MARK: - Public
    
    /// Set Cache
    /// - Parameters:
    ///   - data: Data to save in NSCache
    ///   - key: key for NSCache
    func setCache(_ object: NSData, for key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    /// Get Cache
    /// Check if there is something available in the cache dictionary
    /// - Parameters:
    ///   - key: key for NSCache
    func getCache(for key: String) -> NSData? {
        return cache.object(forKey: key as NSString)
    }

}
