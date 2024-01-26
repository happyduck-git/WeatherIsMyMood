//
//  NSCacheManager.swift
//  WeatherWidgetExtension
//
//  Created by HappyDuck on 1/26/24.
//

import Foundation

protocol Cachable {
    associatedtype Key: NSObject
    associatedtype Value: NSObject
    var cache: NSCache<Key, Value> { get set }
    func setCache(_ object: Value, for key: String)
    func getCache(for key: String) -> Value?
}

final class NSCacheManager: Cachable {
    
    var cache = NSCache<NSString, NSObject>()

}

extension NSCacheManager {
    func setCache(_ object: NSObject, for key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    func getCache(for key: String) -> NSObject? {
        return cache.object(forKey: key as NSString)
    }
}
