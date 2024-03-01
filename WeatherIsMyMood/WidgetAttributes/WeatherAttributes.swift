//
//  WeatherAttributes.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import Foundation
import ActivityKit
import UIKit
import SwiftUI

struct WeatherAttributes: ActivityAttributes {

    let isSystemSetting: Bool
    let bgColor: Color
    let textColor: Color
    let icon: Data
    
    struct ContentState: Codable & Hashable {
        let temperature: String
    }
}
