//
//  TenDayForcastView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct TenDayForcastView: View {
    var dayWeatherList: [DayWeather]
    
    private var today: DayWeather?
    private var otherDays: [DayWeather] = []
    @State private var collapsed: Bool = true
    
    init(dayWeatherList: [DayWeather]) {
        self.dayWeatherList = dayWeatherList
        
        var weatherList = dayWeatherList
        self.today = weatherList.removeFirst()
        self.otherDays = weatherList
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                WeatherTitleView(section: .tenDays)
                    .shadow(radius: 10)
                    .frame(width: 200)
                Spacer()
                Button(action: {
                    self.collapsed.toggle()
                }, label: {
                    HStack {
                        Text(self.collapsed ? WeatherConstants.showMore : WeatherConstants.showLess)
                            .foregroundStyle(.indigo)
                        Image(systemName: self.collapsed ? "chevron.down.circle" : "chevron.up.circle")
                            .foregroundStyle(.indigo)
                    }
                })
                .padding(.horizontal)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            self.makeWeatherRow(self.today)
                .background(
                    LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottom)
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 15.0))
                        .shadow(radius: 10)
                )
            VStack(alignment: .leading) {
 
                ForEach(self.otherDays, id: \.date) { item in
                    self.makeWeatherRow(item)
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .background(
                LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottom)
                    .opacity(0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .shadow(radius: 10)
            )
            .animation(.bouncy, value: collapsed)
            .transition(.slide)
        }     
        
    }
    
    @ViewBuilder
    private func makeWeatherRow(_ weather: DayWeather?) -> some View {
        if let weather {
            VStack {
                HStack {
                    Text(weather.date.abbreviatedDay())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "\(weather.symbolName)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(weather.lowTemperature.formatted())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(weather.highTemperature.formatted())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                
                Divider()
                    .padding(EdgeInsets(top: -10, leading: 10, bottom: -100, trailing: 10))
            }
        } else {
            VStack(content: {
                Text("asdf")
            })
        }
        
    }
    
}

#Preview {
    WeatherView(locationManager: LocationManager(locationFetcher: CLLocationManager()),
                storageManager: FirestoreManager())
}
