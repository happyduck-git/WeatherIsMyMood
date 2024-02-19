
// WeatherCondition+Extensions.swift
// WeatherIsMyMood
//
// Created by HappyDuck on 12/11/23.


import SwiftUI
import WeatherKit

extension WeatherCondition {
    var weatherIcon: String {
        switch self {

        case .blizzard, .snow, .heavySnow, .sunFlurries, .blowingSnow, .flurries, .sleet, .wintryMix:
            "snow"

        case .rain, .heavyRain, .freezingRain:
            "rain"
            
        case .drizzle, .freezingDrizzle, .sunShowers: 
            "drizzle"
             
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            "cloudy"
            
        case .clear, .mostlyClear:
            "sunny"
            
        case .hot:
            "hot"

        case .breezy, .windy, .blowingDust: 
            "windy"
            
        case .hurricane: 
            "tornado"
        
        case .foggy, .haze, .smoky: 
            "haze"
        
        case .frigid:
            "cold"
            
        case .hail: 
            "hail"
        
        case .scatteredThunderstorms, .strongStorms, .thunderstorms, .tropicalStorm, .isolatedThunderstorms: 
            "thunderstorms"
        
        @unknown default:
            "clear"
        }
    }
    
    static func getWeatherNameInSnakeCase(of condition: Self) -> String {
        return condition.rawValue.camelCaseToSnakeCase()
    }
    
    
    
    static func getWeatherIconName(of condition: String) -> String {
        #if DEBUG
        print("Condition: \(condition)")
        #endif
        guard let condition = WeatherCondition(rawValue: condition) else {
            return "sunny"
        }
        return condition.weatherIcon
    }
}

extension UVIndex.ExposureCategory {
    var indexIcon: String {
        switch self {
        case .high, .veryHigh, .extreme:
            return "sun.max.fill"
            
        case .low, .moderate:
            return "sun.min.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .veryHigh, .extreme:
            return .red
        case .high:
            return .orange
        case .low, .moderate:
            return .green
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return WeatherConstants.low
        case .moderate:
            return WeatherConstants.moderate
        case .high:
            return WeatherConstants.high
        case .veryHigh:
            return WeatherConstants.veryHigh
        case .extreme:
            return WeatherConstants.extreme
        }
    }
}

