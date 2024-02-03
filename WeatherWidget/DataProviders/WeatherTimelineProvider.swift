//
//  WeatherTimelineProvider.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import WidgetKit
import WeatherKit
import Intents
import AppIntents
import Combine
import FirebaseStorage
import UIKit

protocol TimelineProviderTask {
    var defaultCityName: String { get }
    var locationManager: LocationManager { get }
    var cacheManager: NSCacheManager { get }
    var weatherService: WeatherService { get }
    var firestoreManager: FirestoreManager { get }
    func makeWeatherEntryWhenLocationNotFound() -> WeatherEntry
    func makeWeatherEntryWhenLocationFound(location: CLLocation, config: CommonIntent) async -> WeatherEntry
}

extension TimelineProviderTask {
    
    var defaultCityName: String { WidgetConstants.appName }
    var weatherService: WeatherService { WeatherService.shared }
    
    func makeWeatherEntryWhenLocationNotFound() -> WeatherEntry {
        /// Check if there is cached data.
        if let cachedData = self.cacheManager.getCache(for: WidgetConstants.entryCache) as? StructWrapper<WeatherEntry> {
            return cachedData.value
        } else {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: UIImage(resource: .weatherMorningBright).pngData(),
                                quote: "No location found")
        }
    }
    
    func makeWeatherEntryWhenLocationFound(location: CLLocation, config: CommonIntent) async -> WeatherEntry {
        do {
            async let cityName = CLLocationManager.cityName(at: location)
            async let weather = weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.weatherIcon)
            
            let entry = try await WeatherEntry(date: Date(),
                                               cityName: cityName ?? self.defaultCityName,
                                               weather: weather,
                                               image: image,
                                               quote: makeQuote(quote: config.quote))
            
            let wrappedEntry: StructWrapper<WeatherEntry> = StructWrapper(entry)
            self.cacheManager.setCache(wrappedEntry, for: WidgetConstants.entryCache)
            
            return entry
        }
        catch {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: UIImage(resource: .weatherMorningBright).pngData(),
                                quote: "\(error)")
        }
    }
    
    private func makeQuote(quote: String?) -> String {
        guard let quote else {
            return WidgetConstants.demoQuote
        }
        return quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? WidgetConstants.demoQuote : quote
    }
    
}

@available(iOS 17.0, *)
struct WeatherTimelineProvider: AppIntentTimelineProvider, TimelineProviderTask {
    typealias Entry = WeatherEntry
    typealias Intent = WeatherAppIntent
    
    var locationManager: LocationManager
    var cacheManager: NSCacheManager
    var firestoreManager: FirestoreManager
    
    init(locationManager: LocationManager,
         cacheManager: NSCacheManager,
         firestoreManager: FirestoreManager) {
        
        self.locationManager = locationManager
        self.cacheManager = cacheManager
        self.firestoreManager = firestoreManager
    }
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: WidgetConstants.demoQuote)
        
    }
    
    func snapshot(for configuration: WeatherAppIntent, in context: Context) async -> WeatherEntry {
        
        guard let location = self.locationManager.locationFetcher.location else {
            return self.makeWeatherEntryWhenLocationNotFound()
        }
        
        return await self.makeWeatherEntryWhenLocationFound(location: location, config: configuration)
    }
    
    func timeline(for configuration: WeatherAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        
        guard let location = self.locationManager.locationFetcher.location else {
            
            let entry = self.makeWeatherEntryWhenLocationNotFound()
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        
        let entry = await makeWeatherEntryWhenLocationFound(location: location, config: configuration)
        return Timeline(entries: [entry],
                        policy: .atEnd)
    }
    
}


struct SiriKitIntentProvider: IntentTimelineProvider, TimelineProviderTask {
    
    typealias Entry = WeatherEntry
    typealias Intent = WeatherSelectionIntent
    
    var locationManager: LocationManager
    var cacheManager: NSCacheManager
    var firestoreManager: FirestoreManager
    
    init(locationManager: LocationManager,
         cacheManager: NSCacheManager,
         firestoreManager: FirestoreManager) {
        
        self.locationManager = locationManager
        self.cacheManager = cacheManager
        self.firestoreManager = firestoreManager
    }
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: "PHWeahterNil")
    }
    
    func getSnapshot(for configuration: WeatherSelectionIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        guard let location = self.locationManager.locationFetcher.location else {
            let entry = self.makeWeatherEntryWhenLocationNotFound()
            completion(entry)
            return
        }
        Task {
            let entry = await makeWeatherEntryWhenLocationFound(location: location, config: configuration)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: WeatherSelectionIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        
        /// When location is not found or granted.
        guard let location = self.locationManager.locationFetcher.location else {
            let entry = self.makeWeatherEntryWhenLocationNotFound()
            let timeline = Timeline(entries: [entry],
                                    policy: .atEnd)
            completion(timeline)
            return
        }
        
        Task {
            let entry = await makeWeatherEntryWhenLocationFound(location: location, config: configuration)
            let timeline = Timeline(entries: [entry],
                                    policy: .atEnd)
            completion(timeline)
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

protocol CommonIntent {
    var quote: String? { get set }
}

extension WeatherSelectionIntent: CommonIntent {}
@available(iOS 17.0, *)
extension WeatherAppIntent: CommonIntent {}
