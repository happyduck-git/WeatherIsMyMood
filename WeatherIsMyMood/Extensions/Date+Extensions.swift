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
    
    /// Return days in abbreviated format.
    /// Return the current day as "Today".
    /// - Returns: Day
    func abbreviatedDay() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return String(localized: "Today")
        }
        return formateAsAbbreviatedDay()
    }
    
    func formatAsAbbreviatedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha" // Custom format: Hour in 12-hour format + AM/PM designator
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
