//
//  DecorateView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct DecorationView: View {
    @StateObject private var locationManager = LocationManager()
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State private var condition: WeatherCondition = .clear
    
    var body: some View {
        VStack {
            Text(condition.rawValue)
        }
        .task(id: locationManager.currentLocation) {
            if let location = locationManager.currentLocation {
                do {
                    self.weather = try await weatherService.weather(for: location)
                }
                catch {
                    print(error)
                }
            }
        }
        .onChange(of: self.weather) { _, newValue in
            if let newValue {
                condition = newValue.currentWeather.condition
            }
        }
    }
}

#Preview {
    DecorationView()
}

extension WeatherCondition {
    var weatherIcon: String {
        switch self {

        case .blizzard, .snow, .heavySnow, .sunFlurries, .blowingSnow:
            "snow"

        case .flurries:
            "snow_flurries"

        case .rain, .heavyRain, .freezingRain:
            "showers"
            
        case .drizzle, .freezingDrizzle, .sunShowers:
            "drizzle"
             
        case .cloudy:
            "cloudy"
        
        case .mostlyCloudy:
            "mostly_cloudy"
            
        case .partlyCloudy:
            "partly_cloudy"
            
        case .clear, .hot:
            "sunny"

        case .mostlyClear:
            "clear_cloudy"
            
        case .breezy, .windy, .blowingDust:
            "windy"
            
        case .hurricane:
            "tornado"
        
        case .foggy, .haze, .smoky:
            "haze"
        
        case .frigid:
            "cold"
            
        case .hail:
            "hail"
      
        case .isolatedThunderstorms:
            "isolated_thunderstroms"
        
        case .scatteredThunderstorms, .strongStorms, .thunderstorms, .tropicalStorm:
            "thunderstroms"
       
        case .sleet, .wintryMix:
            "sleet"
        
        @unknown default:
            "sunny"
        }
    }
}
