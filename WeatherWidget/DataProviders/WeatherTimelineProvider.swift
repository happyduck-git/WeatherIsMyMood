//
//  WeatherTimelineProvider.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import WidgetKit
import WeatherKit
import Intents
import Combine
import FirebaseStorage

@available(iOS 17.0, *)
struct WeatherTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = WeatherEntry
    typealias Intent = WeatherAppIntent
    
    private let weatherService: WeatherService = WeatherService.shared
    private let firestoreManager: FirestoreManager = FirestoreManager()
    private let locationManager: LocationManager
    private let defaultCityName: String = WidgetConstants.appName
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: "PlaceHolder")
        
    }
    
    func snapshot(for configuration: WeatherAppIntent, in context: Context) async -> WeatherEntry {
        
        guard let location = self.locationManager.locationFetcher.location else {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: nil,
                                quote: WidgetConstants.demoQuote)
        }
        do {
            
            async let cityName = CLLocationManager.cityName(at: location)
            async let weather = weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.weatherIcon)
            
            let entry = try await WeatherEntry(date: Date(),
                                               cityName: cityName ?? self.defaultCityName,
                                               weather: weather,
                                               image: image,
                                               quote:  WidgetConstants.demoQuote)
            return entry
        }
        catch WeatherError.unknown,
              WeatherError.permissionDenied {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: nil,
                                quote: "Weather Error")
        }
        catch {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: nil,
                                quote: "\(error)")
        }
       
    }
    
    func timeline(for configuration: WeatherAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        
        guard let location = self.locationManager.locationFetcher.location else {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: "No location found")
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        do {
            async let cityName = CLLocationManager.cityName(at: location)
            async let weather = weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.weatherIcon)
            
            let entry = try await WeatherEntry(date: Date(),
                                               cityName: cityName ?? self.defaultCityName,
                                               weather: weather,
                                               image: image,
                                               quote: configuration.quote ?? WidgetConstants.demoQuote)
            
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        catch {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: "\(error)")
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        
    }

}


struct SiriKitIntentProvider: IntentTimelineProvider {

    typealias Entry = WeatherEntry
    typealias Intent = IntentIntent
    
    private let weatherService: WeatherService = WeatherService.shared
    private let locationManager: LocationManager
    private let firestoreManager: FirestoreManager = FirestoreManager()
   
    private let defaultCityName: String = WidgetConstants.appName
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: WidgetConstants.demoQuote)
    }
    
    func getSnapshot(for configuration: IntentIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        guard let location = self.locationManager.locationFetcher.location else {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: WidgetConstants.demoQuote)
            completion(entry)
            return
        }
        Task {
            do {
                
                async let cityName = CLLocationManager.cityName(at: location)
                async let weather = weatherService.weather(for: location)
                let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.weatherIcon)
                
                let entry = try await WeatherEntry(date: Date(),
                                                   cityName: cityName ?? self.defaultCityName,
                                                   weather: weather,
                                                   image: image,
                                                   quote:  WidgetConstants.demoQuote)
                completion(entry)
            }
            catch WeatherError.unknown,
                  WeatherError.permissionDenied {
                let entry = WeatherEntry(date: Date(),
                                         cityName: self.defaultCityName,
                                         weather: nil,
                                         image: nil,
                                         quote: "Weather Error")
                completion(entry)
            }
            catch {
                let entry = WeatherEntry(date: Date(),
                                         cityName: self.defaultCityName,
                                         weather: nil,
                                         image: nil,
                                         quote: "Storage Error -- \(error)")
                completion(entry)
            }
        }
}
    
    func getTimeline(for configuration: IntentIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {

        guard let location = self.locationManager.locationFetcher.location else {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: "No location found")
            let timeline = Timeline(entries: [entry],
                            policy: .atEnd)
            completion(timeline)
            return
        }
        
        Task {
            do {
                async let cityName = CLLocationManager.cityName(at: location)
                async let weather = weatherService.weather(for: location)
                let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.weatherIcon)
                
                let entry = try await WeatherEntry(date: Date(),
                                                   cityName: cityName ?? self.defaultCityName,
                                                   weather: weather,
                                                   image: image,
                                                   quote: configuration.quote ?? WidgetConstants.demoQuote)
                
                let timeline = Timeline(entries: [entry],
                                policy: .atEnd)
                completion(timeline)
            }
            catch {
                let entry = WeatherEntry(date: Date(),
                                         cityName: self.defaultCityName,
                                         weather: nil,
                                         image: nil,
                                         quote: "\(error)")
                let timeline = Timeline(entries: [entry],
                                policy: .atEnd)
                completion(timeline)
            }
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
