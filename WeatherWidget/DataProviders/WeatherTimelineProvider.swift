//
//  WeatherTimelineProvider.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import WidgetKit
import WeatherKit

struct WeatherTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = WeatherEntry
    typealias Intent = WeatherAppIntent
    
    private let weatherService: WeatherService = WeatherService.shared
    private let locationManager: LocationManager = LocationManager()
    private let firestoreManager: FirestoreManager = FirestoreManager()
    
    private let defaultCityName: String = "Incheon"
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: WidgetConstants.demoQuote)
        
    }
    
    func snapshot(for configuration: WeatherAppIntent, in context: Context) async -> WeatherEntry {
        
        guard let location = locationManager.currentLocation else {
            return self.placeholder(in: context)
        }
        do {
            
            let weather = try await weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
            let entry = WeatherEntry(date: Date(),
                                     cityName: locationManager.cityName ?? self.defaultCityName,
                                     weather: weather,
                                     image: image,
                                     quote: configuration.quote ?? WidgetConstants.demoQuote)
            return entry
        }
        catch {
            return self.placeholder(in: context)
        }

       
    }
    
    func timeline(for configuration: WeatherAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        guard let location = locationManager.currentLocation else {
            return Timeline(entries: [self.placeholder(in: context)],
                            policy: .atEnd)
        }
        do {
            let weather = try await weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
            let entry = WeatherEntry(date: Date(),
                                     cityName: locationManager.cityName ?? self.defaultCityName,
                                     weather: weather,
                                     image: image,
                                     quote: configuration.quote ?? WidgetConstants.demoQuote)
            
            // TODO: Might need to change update policy.
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        catch {
            return Timeline(entries: [self.placeholder(in: context)],
                            policy: .atEnd)
        }
        
        
        
    }

}

struct WeatherEntry: TimelineEntry {
    public let date: Date
    let cityName: String
    let weather: Weather?
    let image: Data?
    var quote: String
}
