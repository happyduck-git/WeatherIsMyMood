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
    ///   - key: Firebase Storage path
    func setCache(_ object: NSData, for key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    /// Get Cache
    /// Check if there is something available in the cache dictionary
    /// - Parameters:
    ///   - key: Firebase Storage path
    func getCache(for key: String) -> NSData? {
        return cache.object(forKey: key as NSString)
    }
    
    /* Delete Below Two Functions After Testing Above Functions */
    /// Get Cache
    /// Check if there is something available in the cache dictionary
    /// - Parameters:
    ///   - path: Firebase Storage path
    public func cachedResponse(for path: String) -> Data? {
        let key = path as NSString
        return cache.object(forKey: key) as? Data
    }
    
    /// Set Cache
    /// - Parameters:
    ///   - path: Firebase Storage path
    ///   - data: data to save in NSCache
    public func setCache(for path: String, data: Data?) {
        guard let data = data else { return }
        let key = path as NSString
        let nsdata = data as NSData
        cache.setObject(nsdata, forKey: key)
    }
}
