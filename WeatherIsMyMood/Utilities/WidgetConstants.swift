//
//  AppConstants.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

enum UserDefaultsKeys {
    static let deviceToken = "device-token"
}

enum BGTaskConstants {
    static let testId = "com.gghoneycomb.WeatherIsMyMood.bg_test"
    static let weatherUpdateId = "com.gghoneycomb.WeatherIsMyMood.bg_weather_update"
}

enum NotificationKeys {
    static let widgetUpdate = "widget_update"
    static let systemWidgetUpdate = "sys_widget_update"
    static let backgroundUpdate = "bg_weather_update"
    static let demoNoti = "demo_noti"
}

enum ColorConstants {
    static let main = "Main"
    static let widgetMain = "WidgetBG"
}

enum WeatherConstants {
    static let hourlyWeather = String(localized: "Hourly Weather")
    static let tenDayForcast = String(localized: "10-Day Forcast")
    static let precipitation = String(localized: "Precipitation")
    static let aqForcast = String(localized: "AQ Forcast")
    static let airQuality = String(localized: "Air Quality")
    static let weather = String(localized: "Weather")
    static let deco = String(localized: "Deco")
    static let weatherDataAttribution = String(localized: "Weather Data Attribution")
    static let city = String(localized: "City")
    static let feelsLike = String(localized: "Feels Like")
    static let humidity = String(localized: "Humidity ")
    static let uvIndex = String(localized: "UV Index ")
    static let showMore = String(localized: "Show more")
    static let showLess = String(localized: "Show less")
    static let previewDescription = String(localized: "Tap on an icon you like \nand see how it looks on dynamic island!")
    static let showAirQuality = String(localized: "Air quality")
    static let noDataFound = String(localized: "No data found")
    static let good = String(localized: "Good")
    static let fair = String(localized: "Fair")
    static let moderate = String(localized: "Moderate")
    static let poor = String(localized: "Poor")
    static let veryPoor = String(localized: "Very Poor today")
    static let goodLong = String(localized: "Good today")
    static let fairLong = String(localized: "Fair today")
    static let moderateLong = String(localized: "Moderate today")
    static let poorLong = String(localized: "Poor today")
    static let veryPoorLong = String(localized: "Very Poor today")
    static let low = String(localized: "Low")
    static let high = String(localized: "High")
    static let veryHigh = String(localized: "Very high")
    static let extreme = String(localized: "Extreme")
    static let so2 = String(localized: "Sulfur dioxide")
    static let no2 = String(localized: "Nitrogen dioxide")
    static let pm10 = String(localized: "PM-10")
    static let pm2_5 = String(localized: "PM-2.5")
    static let o3 = String(localized: "Ozone")
    static let co = String(localized: "Carbon monoxide")
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
