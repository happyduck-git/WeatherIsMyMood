//
//  HourlyPrecipitationChartView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit
import Charts

struct HourlyPrecipitationChartView: View {
    @Binding var hourWeatherList: [HourWeather]
    @State var noPrecipitation = Set<Bool>()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                WeatherTitleView(title: "Precipitation")
                    .shadow(radius: 10)
                if noPrecipitation.contains(true) {
                    Text("No rain is expected for 7hrs!")
                        .padding()
                }
                
                Chart {
                    ForEach(hourWeatherList.prefix(7), id: \.date) { weather in
                        BarMark(
                            x: .value("Hour", weather .date.formatAsAbbreviatedTime()),
                            y: .value("Precipitation", weather.precipitationChance.rounded())
                        )
                        .shadow(radius: 3)
                        .opacity(0.9)
                        .foregroundStyle(.indigo)
                        
                    }
                }
                .padding()
                
            }
        }
        .background {
            LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottom)
                .opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 10)
        }
        .onChange(of: hourWeatherList) { _, _ in
            self.checkForPrecipitation()
            print(noPrecipitation)
        }
    }
}

extension HourlyPrecipitationChartView {
    private func checkForPrecipitation() {
        noPrecipitation.insert(hourWeatherList.prefix(7).contains { $0.precipitationAmount.value.rounded().isZero })
    }
}

#Preview {
    WeatherView()
}
