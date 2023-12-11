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
    
    let dailyWeather: DayWeather
    let status: Status
    @State var dateTime: String = "aa"
    
    var body: some View {
        VStack {
            Image(systemName: self.status.rawValue)
                .foregroundStyle(status == .sunrise ? .orange : .indigo)
            Text(dateTime)
        }
        .onAppear(perform: {
            updateDateTime()
        })
        
    }
    
    private func updateDateTime() {
            switch status {
            case .sunrise:
                self.dateTime = dailyWeather.sun.sunrise?.formatted(.dateTime.hour().minute()) ?? "?"
            case .sunset:
                self.dateTime = dailyWeather.sun.sunset?.formatted(.dateTime.hour().minute()) ?? "?"
            }
        }
}

#Preview {
    WeatherView()
}
