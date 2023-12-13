//
//  Double+Extensions.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

extension Double {
    func roundUpToTwoDecimalPlaces() -> Double {
        return (self * 100).rounded() / 100
    }
    
    func showTwoDecimalPlaces() -> String {
        return String(format: "%.2f", self)
    }
}
