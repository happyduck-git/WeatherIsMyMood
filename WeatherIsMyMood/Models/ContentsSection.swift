//
//  ContentsSection.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/17/24.
//

import SwiftUI
 
enum ContentsSection {
    case hourlyWeather
    case tenDays
    case airQuality
    case precipitation
    case weatherIcons
    case emojis
    
    var title: String {
        switch self {
        case .hourlyWeather:
            return WeatherConstants.hourlyWeather
        case .tenDays:
            return WeatherConstants.tenDayForcast
        case .airQuality:
            return WeatherConstants.aqForcast
        case .precipitation:
            return WeatherConstants.precipitation
        case .weatherIcons:
            return DecoConstants.weather
        case .emojis:
            return DecoConstants.others
        }
    }
    
    var icon: String {
        switch self {
        case .hourlyWeather:
            return "sun.max.fill"
        case .tenDays:
            return "list.clipboard"
        case .airQuality:
            return "aqi.medium"
        case .precipitation:
            return "cloud.rain.fill"
        case .weatherIcons:
            return "sun.dust.fill"
        case .emojis:
            return "gamecontroller.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .hourlyWeather:
            return .orange
        case .tenDays:
            return .teal
        case .airQuality:
            return .gray
        case .precipitation:
            return .blue
        case .weatherIcons:
            return .skyblue
        case .emojis:
            return .yellow
        }
    }
}
