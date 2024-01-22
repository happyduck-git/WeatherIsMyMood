
// WeatherCondition+Extensions.swift
// WeatherIsMyMood
//
// Created by HappyDuck on 12/11/23.


import Foundation
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
