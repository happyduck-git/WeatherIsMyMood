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
        HStack {
            WeatherTitleView(section: .hourlyWeather)
                .shadow(radius: 10)
                .frame(width: 200)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            Spacer()
        }
    
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(hourWeatherList, id: \.date) { item in
                        VStack(spacing: 10) {
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
