//
//  WeatherAttributes.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import Foundation
import ActivityKit
import UIKit.UIImage

struct WeatherAttributes: ActivityAttributes {
//    typealias WeatherAttributes = ContentState
    
    struct ContentState: Codable & Hashable {
        // Live Activities Will be Updated Its View When Content State is Updated.
        let icon: Data
        let temperature: String
    }
}
