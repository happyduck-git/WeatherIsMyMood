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
    
    func showDecimalTo(number: Int) -> String {
        return String(format: "%.\(number)f", self)
    }
    
    func convertToTempFormat(decimal: Int) -> String {
        let numStr = showDecimalTo(number: decimal)
        if !numStr.contains(/[1-9]/) && numStr.hasPrefix("-") {
            return String(numStr.trimmingPrefix("-"))
        } else {
            return numStr
        }
    }

}
