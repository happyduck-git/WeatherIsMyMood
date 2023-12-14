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
        if formatter.locale == Locale(identifier: "ko_KR") {
            formatter.dateFormat = "aK시"
        } else {
            formatter.dateFormat = "ha"
        }
    
        return formatter.string(from: self)
    }
}
