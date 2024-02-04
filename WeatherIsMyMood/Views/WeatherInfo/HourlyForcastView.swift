//
//  HourlyForcastView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit
struct HourlyForcastView: View {
    let hourWeatherList: [HourWeather]
    
    var body: some View {
        ZStack {
      
            VStack(alignment: .leading, content: {
                
                WeatherTitleView(title: WeatherConstants.hourlyWeather)
                    .shadow(radius: 10)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(hourWeatherList, id: \.date) { item in
                            VStack(spacing: 20) {
                                Text(item.date.formatAsAbbreviatedTime())
                                Image(systemName: "\(item.symbolName)")
                                    .foregroundStyle(.secondary)
                                Text(item.temperature.formatted())
                                    .fontWeight(.bold)
                            }
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            })
            
        }
        .foregroundColor(.primary)
        .background {
            LinearGradient(colors: [.red, .pink, .red], startPoint: .topLeading, endPoint: .bottom)
                .opacity(0.6)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 10)
        }
    }
}
