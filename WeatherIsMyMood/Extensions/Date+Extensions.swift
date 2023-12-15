//
//  Date+Extensions.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import Foundation

extension Date {
    func formateAsAbbreviatedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    func formatAsAbbreviatedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha" // Custom format: Hour in 12-hour format + AM/PM designator
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
