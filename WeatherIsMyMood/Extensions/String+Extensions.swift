//
//  File.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/21/24.
//

import Foundation

extension String {
    func roundDecimalPlace(to length: Int) -> String {
        guard let number = Double(self) else {
            return self // Return the original string if it's not a valid number
        }
   
        return String(format: "%.\(length)f", number)
    }
}

extension String {
    func addTemparatureUnit() -> String {
        return "\(self)\("˚")"
    }
}
