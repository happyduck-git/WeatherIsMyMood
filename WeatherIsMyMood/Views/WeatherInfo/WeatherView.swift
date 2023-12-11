//
//  ContentView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import SwiftUI
import WeatherKit

struct WeatherView: View {
    
    @StateObject private var locationManager = LocationManager()
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State var hourlyWeatehrData: [HourWeather] = []
    
    @State var attribution: WeatherAttribution?
    @State private var cityName: String = ""
    @State private var searchedCityName: String = ""
    @State var locationNotFound: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ZStack {
                    AppColors.main
                    
                    if !locationNotFound {
                        if let weather {
                       
                                LazyVStack(pinnedViews: [.sectionHeaders]) {
                                    Section {
                                        CityCurrentWeatherView(weather: $weather,
                                                               cityName: $cityName)
                                        
                                        HourlyForcastView(hourWeatherList: self.hourlyWeatehrData)
                                        
                                        TenDayForcastView(dayWeatherList: weather.dailyForecast.forecast)
                                        
                                        HourlyPrecipitationChartView(hourWeatherList: self.$hourlyWeatehrData)
                                        
                                        DataAttributionView(weatherAttribution: self.attribution)
                                            .padding(EdgeInsets(top: 30, leading: 0, bottom: 10, trailing: 0))
                                    } header: {

                                        SearchView(searchCity: $searchedCityName) {
                                            self.updateLocationStatus(to: searchedCityName)
                                        } backToCurrentLocation: {
                                            self.locationManager.requestOnTimeLocation()
                                            self.updateLocationStatus(to: self.locationManager.cityName ?? "Seoul")
                                        }
                                        .frame(width: UIScreen.screenWidth)
                                    }
                                
                            }
                            .padding()
                            
                        }
                    } else {
                        Text("Location not found\nPleas search other location!")
                        Spacer()
                    }
                }
                
            }
            .toolbarBackground(AppColors.main, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                            Image(.logo)
                                .resizable()
                                .frame(width: 40, height: 50, alignment: .bottom)
                                .aspectRatio(contentMode: .fit)
                    }
            })
            
        }
        .task(id: locationManager.currentLocation) {
            if let location = locationManager.currentLocation {
                do {
                    self.weather = try await weatherService.weather(for: location)
                    self.attribution = try await weatherService.attribution
                    locationManager.cityName(at: location, completion: { name in
                        if let name {
                            self.cityName = name
                        }
                    })
                    self.hourlyWeatehrData = Array(weather?.hourlyForecast.filter({ weather in
                               weather.date.timeIntervalSince(Date()) >= 0
                    }).prefix(24) ?? [])
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

extension WeatherView {
    private func updateLocationStatus(to city: String) {
        self.locationManager.location(forCity: city) { loc in
            if let loc {
                locationNotFound = false
                locationManager.currentLocation = loc
            } else {
                locationNotFound = true
            }
        }
    }
}

#Preview {
    WeatherView()
}
