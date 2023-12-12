//
//  ContentView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import SwiftUI
import WeatherKit

struct WeatherView: View {
    
    @State private var isFirstLoading = true
    @State private var isLoading = false
    
    @StateObject private var locationManager = LocationManager()
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State var hourlyWeatherData: [HourWeather] = []
    
    @State var attribution: WeatherAttribution?
    @State private var cityName: String = ""
    @State private var searchedCityName: String = ""
    @State var locationFound: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                
                self.makeScrollView()
                
                if isLoading {
                    LoadingView()
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
        .onAppear() {
            if self.isFirstLoading {
                self.isFirstLoading.toggle()
                self.isLoading = true
            }
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
                    self.hourlyWeatherData = Array(weather?.hourlyForecast.filter({ weather in
                        weather.date.timeIntervalSince(Date()) >= 0
                    }).prefix(24) ?? [])
                    
                    self.isLoading = false
                }
                catch {
                    print(error)
                }
            }
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .onChange(of: self.searchedCityName) {
            self.locationFound = true
        }
    }
}

extension WeatherView {
    private func makeScrollView() -> some View {
        ScrollView(.vertical) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                Section {
                    if !locationFound {
                        Text("Location not found.\nPlease search other location!")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red.opacity(0.9))
                            .padding()
                    }
                    if let weather {
                        CityCurrentWeatherView(weather: $weather,
                                               cityName: $cityName)
                        
                        HourlyForcastView(hourWeatherList: self.hourlyWeatherData)
                        
                        TenDayForcastView(dayWeatherList: weather.dailyForecast.forecast)
                        
                        HourlyPrecipitationChartView(hourWeatherList: self.$hourlyWeatherData)
                        
                        DataAttributionView(weatherAttribution: self.attribution)
                            .padding(EdgeInsets(top: 30, leading: 0, bottom: 10, trailing: 0))
                    } else {
                        AppColors.main
                            .ignoresSafeArea()
                    }
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
        .background {
            AppColors.main
                .ignoresSafeArea()
        }
    }
}

extension WeatherView {
    private func updateLocationStatus(to city: String) {
        if !city.isEmpty {
            self.locationManager.location(forCity: city) { loc in
                if let loc {
                    self.locationFound = true
                    self.locationManager.currentLocation = loc
                } else {
                    self.locationFound = false
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}
