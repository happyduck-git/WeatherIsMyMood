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
//    typealias WeatherAttributes = ContentState
    let bgColors: Color
    let textColors: Color
    let icon: Data
    
    struct ContentState: Codable & Hashable {
        let temperature: String
    }
}

extension Optional: RawRepresentable where Wrapped: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else {
            return "{}"
        }
        return String(decoding: data, as: UTF8.self)
    }

    public init?(rawValue: String) {
        guard let value = try? JSONDecoder().decode(Self.self, from: Data(rawValue.utf8)) else {
            return nil
        }
        self = value
    }
}

