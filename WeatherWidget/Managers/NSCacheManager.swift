//
//  NSCacheManager.swift
//  WeatherWidgetExtension
//
//  Created by HappyDuck on 1/26/24.
//

import Foundation

final class NSCacheManager {
    
    private var cache = NSCache<NSString, NSObject>()

}

extension NSCacheManager {
    func setCache(_ object: NSObject, for key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    func getCache(for key: String) -> NSObject? {
        return cache.object(forKey: key as NSString)
    }
}
