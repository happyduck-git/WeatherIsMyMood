//
//  SunTimeView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct SunStatusTimeView: View {
    enum Status: String {
        case sunrise
        case sunset
    }
    
    let status: Status
    @Binding var weather: Weather?
    @State var dateTime = String()
    
    var body: some View {
        VStack {
            Image(systemName: self.status.rawValue)
                .foregroundStyle(status == .sunrise ? .orange : .indigo)
            Text(dateTime)
        }
        .task(id: self.weather) {
            if let weather,
               let latestForcast = weather.dailyForecast.last {
                self.updateDateTime(latestForcast)
            }
        }
    }
    
    private func updateDateTime(_ dayWeather: DayWeather) {
            switch status {
            case .sunrise:
                self.dateTime = dayWeather.sun.sunrise?.formatted(.dateTime.hour().minute()) ?? "?"
            case .sunset:
                self.dateTime = dayWeather.sun.sunset?.formatted(.dateTime.hour().minute()) ?? "?"
            }
        }
}

#Preview {
    WeatherView()
}
