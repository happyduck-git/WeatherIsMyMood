//
//  AppConstants.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

enum ColorConstants {
    static let main = "Main"
    static let widgetMain = "WidgetBG"
}

enum WeatherConstants {
    static let hourlyWeather = String(localized: "Hourly Weather")
    static let tenDayForcast = String(localized: "10-Day Forcast")
    static let precipitation = String(localized: "Precipitation")
    static let weather = String(localized: "Weather")
    static let deco = String(localized: "Deco")
    static let weatherDataAttribution = String(localized: "Weather Data Attribution")
    static let city = String(localized: "City")
}

enum DecoConstants {
    static let enable = String(localized: "Enable Dynamic Island")
    static let weather = String(localized: "Weather")
    static let preview = String(localized: "Preview")
    static let others = String(localized: "Others")
}

enum WidgetConstants {
    static let widgetKind = "WeatherWidget"
    
    static let appName = String(localized: "Weather Island")
    static let currentTemp = String(localized: "Current Temp")
    static let personalQuote = String(localized: "Personal Quote")
    
    static let condition = String(localized: "Condition")
    static let precipitation = String(localized: "Precip")
    static let humidity = String(localized: "Humidity")
    static let wind = String(localized: "Wind")
    static let highest = String(localized: "H")
    static let lowest = String(localized: "L")
    
    static let precipitationUnit = String(localized: "%")
    static let humidityUnit = String(localized: "%")
    static let windUnit = String(localized: "m/s")
    
    static let demoQuote = String(localized: "Your quote here 🙂")
    
    static let loadingError = String(localized: "Loading weather data...")
    
    static let entryCache = "WidgetEntry"
}
