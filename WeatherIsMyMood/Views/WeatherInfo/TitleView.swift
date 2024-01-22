//
//  TitleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct TitleView: View {
    @Binding var cityName: String
    @Binding var weather: Weather?
    
    var body: some View {
        if let weather {
            Text(cityName)
                .font(.largeTitle)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            Text(weather.currentWeather.temperature.value.showTwoDecimalPlaces()+"\(weather.currentWeather.temperature.unit.symbol)")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                .opacity(0.8)
        }
    }
}

