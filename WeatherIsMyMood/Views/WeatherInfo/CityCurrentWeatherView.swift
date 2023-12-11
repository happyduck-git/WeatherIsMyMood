//
//  CityCurrentWeatherView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit

struct CityCurrentWeatherView: View {
    
    @Binding var weather: Weather?
    @Binding var cityName: String
    
    var body: some View {
        if let weather {
            ZStack {

                Image(.weatherNightColdSnow)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.5)
                
                Circle()
                    .fill(.clear)
                    .background {
                        LinearGradient(
                            colors: [.clear,
                                     .white.opacity(0.6),
                                     .clear],
                            startPoint: .top,
                            endPoint: .bottomTrailing
                        )
                        
                        .clipShape(Circle())
                    }
                    
                VStack {
                    TitleView(cityName: $cityName,
                              weather: $weather)
                  
                        HStack {
                            SunStatusTimeView(dailyWeather: weather.dailyForecast[0], status: .sunrise)
                                .padding()
                            SunStatusTimeView(dailyWeather: weather.dailyForecast[0], status: .sunset)
                                .padding()
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.3))
                        }
                        
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}
