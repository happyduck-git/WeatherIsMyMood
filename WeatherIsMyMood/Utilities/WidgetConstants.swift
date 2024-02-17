//
//  AppConstants.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import Foundation

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
    static let weather = String(localized: "Weather")
    static let deco = String(localized: "Deco")
    static let weatherDataAttribution = String(localized: "Weather Data Attribution")
    static let city = String(localized: "City")
    static let feelsLike = String(localized: "Feels Like")
    static let humidity = String(localized: "Humidity ")
    static let uvIndex = String(localized: "UV Index ")
    static let showMore = String(localized: "Show more")
    static let showLess = String(localized: "Show less")
    static let previewDescription = String(localized: "Tap on an icon you like and see how it looks on dynamic island!") //"마음에 드는 아이콘을 눌러서 다이나믹 아일랜드에 \n어떻게 표시되는 지 확인해보세요!"
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
