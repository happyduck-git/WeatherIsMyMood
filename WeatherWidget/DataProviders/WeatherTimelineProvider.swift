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

@available(iOS 17.0, *)
struct WeatherTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = WeatherEntry
    typealias Intent = WeatherAppIntent
    
    private let weatherService: WeatherService = WeatherService.shared
    private let firestoreManager: FirestoreManager = FirestoreManager()
    
    /* */
    private let locationMG = LocationManager.locationManager
    
    /* */
    private let defaultCityName: String = "GGWorld"
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(),
                            cityName: self.defaultCityName,
                            weather: nil,
                            image: nil,
                            quote: "PlaceHolder")
        
    }
    
    func snapshot(for configuration: WeatherAppIntent, in context: Context) async -> WeatherEntry {
        
        guard let location = locationMG.location else {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: nil,
                                quote: "Snapshot1")
        }
        do {
            
            async let cityName = LocationManager.cityName(at: location)
            async let weather = weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
            
            let entry = try await WeatherEntry(date: Date(),
                                               cityName: cityName ?? self.defaultCityName,
                                               weather: weather,
                                               image: image,
                                               quote: "Snapshot3")
            return entry
        }
        catch {
            return WeatherEntry(date: Date(),
                                cityName: self.defaultCityName,
                                weather: nil,
                                image: nil,
                                quote: "Snapshot2")
        }

       
    }
    
    func timeline(for configuration: WeatherAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        
        guard let location = locationMG.location else {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: "Timeline1")
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        do {
            async let cityName = LocationManager.cityName(at: location)
            async let weather = weatherService.weather(for: location)
            let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
            
            let entry = try await WeatherEntry(date: Date(),
                                               cityName: cityName ?? self.defaultCityName,
                                               weather: weather,
                                               image: image,
                                               quote: "\(weather.currentWeather.condition.rawValue)")
            
            // TODO: Might need to change update policy.
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        catch {
            let entry = WeatherEntry(date: Date(),
                                     cityName: self.defaultCityName,
                                     weather: nil,
                                     image: nil,
                                     quote: "Timeline3")
            return Timeline(entries: [entry],
                            policy: .atEnd)
        }
        
    }

}


struct SiriKitIntentProvider: IntentTimelineProvider {

    typealias Entry = WeatherEntry
    typealias Intent = IntentIntent
    
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
    
    func getSnapshot(for configuration: IntentIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        guard let location = locationManager.currentLocation else {
            completion(self.placeholder(in: context))
            return
        }
        Task {
            do {
                
                let weather = try await weatherService.weather(for: location)
                let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
                let entry = WeatherEntry(date: Date(),
                                         cityName: locationManager.cityName ?? self.defaultCityName,
                                         weather: weather,
                                         image: image,
                                         quote: configuration.quote ?? WidgetConstants.demoQuote)
                completion(entry)
            }
            catch {
                completion(self.placeholder(in: context))
                return
            }
        }
        
    }
    
    func getTimeline(for configuration: IntentIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        guard let location = locationManager.currentLocation else {
            completion(Timeline(entries: [self.placeholder(in: context)],
                                policy: .atEnd))
            return
        }
        Task {
            do {
                
                let weather = try await weatherService.weather(for: location)
                let image = try await firestoreManager.fetchBackground(weather.currentWeather.condition.rawValue)
                let entry = WeatherEntry(date: Date(),
                                         cityName: locationManager.cityName ?? self.defaultCityName,
                                         weather: weather,
                                         image: image,
                                         quote: configuration.quote ?? WidgetConstants.demoQuote)
                completion(Timeline(entries: [entry],
                                    policy: .atEnd))
            }
            catch {
                completion(Timeline(entries: [self.placeholder(in: context)],
                                    policy: .atEnd))
                return
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
