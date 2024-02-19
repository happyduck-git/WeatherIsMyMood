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
    @Binding var weather: Weather?
    
    @State var dayWeatherList: [DayWeather] = []
    
    private var today: DayWeather? {
        dayWeatherList.first
    }
    
    private var otherDays: [DayWeather] {
        Array(dayWeatherList.dropFirst())
    }
    
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                SectionTitleView(section: .tenDays)
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
                    makeGradientBackgound()
                )
            VStack(alignment: .leading) {
 
                ForEach(self.otherDays, id: \.date) { item in
                    self.makeWeatherRow(item)
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .background(
                makeGradientBackgound()
            )
            .animation(.bouncy, value: collapsed)
            .transition(.slide)
        }
        .onAppear {
            self.processWeather()
        }
        .modify {
            if #available(iOS 17.0, *) {
                $0.onChange(of: self.weather) {
                    self.processWeather()
                }
            } else {
                $0.onChange(of: weather) { _ in
                    self.processWeather()
                }
            }
        }
    }
    
}

//MARK: - Process Data
extension TenDayForcastView {
    private func processWeather() {
        self.dayWeatherList = weather?.dailyForecast.forecast.compactMap { $0 } ?? []
    }
}

//MARK: - Make View
extension TenDayForcastView {
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
                Text(WeatherConstants.noDataFound)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            })
        }
    }
    
    private func makeGradientBackgound() -> some View {
        LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottom)
            .opacity(0.3)
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .shadow(radius: 10)
    }
}

#Preview {
    WeatherView(locationManager: LocationManager(locationFetcher: CLLocationManager()),
                storageManager: FirestoreManager())
}
