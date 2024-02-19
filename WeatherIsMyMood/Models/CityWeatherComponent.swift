//
//  CityWeatherComponent.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/17/24.
//

import SwiftUI
import WeatherKit

enum CityWeatherComponent {

    case feelsLike(weather: Weather?)
    case humidity(weather: Weather?)
    case uvIndex(weather: Weather?)
    
    var title: String {
        switch self {
        case .feelsLike(_):
            return WeatherConstants.feelsLike
        case .humidity(_):
            return WeatherConstants.humidity
        case .uvIndex(_):
            return WeatherConstants.uvIndex
        }
    }
    
    var value: String {
        switch self {
        case .feelsLike(let weather):
            return "\(weather?.currentWeather.apparentTemperature.value.convertToTempFormat(decimal: 2) ?? "0")\(weather?.currentWeather.apparentTemperature.unit.symbol ?? "˚C")"
        case .humidity(let weather):
            return "\(weather?.currentWeather.humidity.convertToTempFormat(decimal: 2) ?? "0")%"
        case .uvIndex(let weather):
            return weather?.currentWeather.uvIndex.category.description ?? WeatherConstants.moderate
        }
    }
    
    var icon: String {
        switch self {
        case .feelsLike(_):
            return "thermometer.variable.and.figure.circle"
        case .humidity(_):
            return "humidity.fill"
        case .uvIndex(let weather):
            return weather?.currentWeather.uvIndex.category.indexIcon ?? "sun.min.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .feelsLike(_):
            return .black
        case .humidity(_):
            return .blue
        case .uvIndex(let weather):
            return weather?.currentWeather.uvIndex.category.iconColor ?? .blue
        }
    }
}
