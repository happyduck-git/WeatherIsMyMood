//
//  WeatherCondition+Extensions.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import Foundation
import WeatherKit

extension WeatherCondition {
    var weatherIcon: String {
        switch self {

        case .blizzard, .snow, .heavySnow, .sunFlurries, .blowingSnow:
            "snow"

        case .flurries:
            "snow_flurries"

        case .rain, .heavyRain, .freezingRain:
            "showers"
            
        case .drizzle, .freezingDrizzle, .sunShowers:
            "drizzle"
             
        case .cloudy:
            "cloudy"
        
        case .mostlyCloudy:
            "mostly_cloudy"
            
        case .partlyCloudy:
            "partly_cloudy"
            
        case .clear, .hot:
            "sunny"

        case .mostlyClear:
            "clear_cloudy"
            
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
      
        case .isolatedThunderstorms:
            "isolated_thunderstroms"
        
        case .scatteredThunderstorms, .strongStorms, .thunderstorms, .tropicalStorm:
            "thunderstroms"
       
        case .sleet, .wintryMix:
            "sleet"
        
        @unknown default:
            "sunny"
        }
    }
}
