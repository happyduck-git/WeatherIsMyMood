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

extension String {
    func camelCaseToSnakeCase() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        let result = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1 $2")
        return result.lowercased()
    }
}
