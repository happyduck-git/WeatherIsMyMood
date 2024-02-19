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
    @State var noPrecipitation: Bool = false
    @State var isLoading: Bool = true
    private let numberOfDays: Int = 7
    
    var body: some View {
        
        HStack {
            SectionTitleView(section: .precipitation)
                .shadow(radius: 10)
                .frame(width: 200)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            Spacer()
        }
        
        
        VStack(alignment: .leading) {
            
            if noPrecipitation {
                Text("No rain is expected for 7hrs!")
                    .padding()
            }
            Chart {
                ForEach(hourWeatherList.prefix(7), id: \.date) { weather in
                    BarMark(
                        x: .value("Hour", weather.date.formatAsAbbreviatedTime()),
                        y: .value("Precipitation", weather.precipitationChance.rounded())
                    )
                    .opacity(0.9)
                    .foregroundStyle(.indigo)
                }
            }
            .padding()
        }
        .background {
            LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottom)
                .opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 10)
        }
        .onAppear {
            self.checkForPrecipitation(days: self.numberOfDays)
        }
        .modify {
            if #available(iOS 17.0, *) {
                $0.onChange(of: hourWeatherList) {
                    self.checkForPrecipitation(days: self.numberOfDays)
                }
            } else {
                $0.onChange(of: hourWeatherList) { _ in
                    self.checkForPrecipitation(days: self.numberOfDays)
                }
            }
        }
    }
}

extension HourlyPrecipitationChartView {
    private func checkForPrecipitation(days: Int) {
        let noRainDays = hourWeatherList.prefix(days).filter {$0.precipitationAmount.value.isZero}.count
        if noRainDays == days {
            noPrecipitation = true
        } else {
            noPrecipitation = false
        }
    }
}
