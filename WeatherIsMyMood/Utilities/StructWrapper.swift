//
//  StructWrapper.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/27/24.
//

import Foundation

final class StructWrapper<T>: NSObject {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}
