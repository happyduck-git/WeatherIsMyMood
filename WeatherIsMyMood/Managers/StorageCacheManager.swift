//
//  StorageCacheManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

final class StorageCacheManager {
    private var cacheDictionary = NSCache<NSString, NSData>()
    
    static let shared = StorageCacheManager()
    private init() {}
}

extension StorageCacheManager {
    //MARK: - Public
    
    /// Get Cache
    /// Check if there is something available in the cache dictionary
    /// - Parameters:
    ///   - path: Firebase Storage path
    public func cachedResponse(for path: String) -> Data? {
        let key = path as NSString
        return cacheDictionary.object(forKey: key) as? Data
    }
    
    /// Set Cache
    /// - Parameters:
    ///   - path: Firebase Storage path
    ///   - data: data to save in NSCache
    public func setCache(for path: String, data: Data?) {
        guard let data = data else { return }
        let key = path as NSString
        let nsdata = data as NSData
        cacheDictionary.setObject(nsdata, forKey: key)
    }
}
