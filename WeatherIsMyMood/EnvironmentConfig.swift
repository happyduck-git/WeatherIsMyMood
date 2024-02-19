//
//  EnvironmentConfig.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import Foundation

public enum EnvironmentConfig {
    enum Keys: String {
        case openWeatherApiKey = "OPEN_WEATHER_API_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let openWeatherApiKey: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.openWeatherApiKey.rawValue] as? String else {
            fatalError("openWeatherApiKey is not set in plist for this environment")
        }
        
        return value
    }()
    
}
