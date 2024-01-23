//
//  ContentView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherView: View {
    
    private var locationManager: LocationManager
    
    @State private var isFirstLoading = true
    @State private var isLoading = false
    
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State var hourlyWeatherData: [HourWeather] = []
    
    @State var attribution: WeatherAttribution?
    @State private var cityName: String = ""
    @State private var searchedCityName: String = ""
    @State var locationFound: Bool = true
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                self.makeScrollView()
                
                if isLoading {
                    LoadingView()
                }
            }
            .toolbarBackground(Color(ColorConstants.main), for: .navigationBar)
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
                #if DEBUG
                print("Loc on weatherView: \(location)")
                #endif
                do {
                    async let weather = weatherService.weather(for: location)
                    async let attribution = weatherService.attribution
                    async let cityName = CLLocationManager.cityName(at: location)
                    
                    self.weather = try await weather
                    self.attribution = try await attribution
                    if let unwrappedCityName = await cityName {
                        self.cityName = unwrappedCityName
                    } else {
                        self.locationFound = false
                    }
                    
                    self.hourlyWeatherData = self.filterHours(of: self.weather?.hourlyForecast, count: 24)
                    
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
        .onChange(of: self.searchedCityName, perform: { _ in
            self.locationFound = true
        })
        
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
                        Color(ColorConstants.main)
                            .ignoresSafeArea()
                    }
                } header: {
                    
                    SearchView(searchCity: $searchedCityName) {
                        self.updateLocationStatus(to: searchedCityName)
                        self.demoUpdateLocation(to: searchedCityName)
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
            Color(ColorConstants.main)
                .ignoresSafeArea()
        }
    }
}

extension WeatherView {
    private func updateLocationStatus(to city: String) {
        if !city.isEmpty {
            Task {
                let loc = await self.locationManager.locationFetcher.location(forCity: city, geocoder: CLGeocoder())
                guard let loc else {
                    self.locationFound = false
                    return
                }
                self.locationFound = true
                self.locationManager.currentLocation = loc
            }
        }
    }
    
    private func demoUpdateLocation(to city: String) {
    
            Task {
                let loc = await self.locationManager.locationFetcher.location(forCity: city, geocoder: CLGeocoder())
                guard let loc else {
                   print("No location found \(city)")
                    return
                }
                print("DEMO City \(city): \(loc.coordinate)")
            }
        
    }

    private func filterHours(of hourlyWeathers: Forecast<HourWeather>?, count: Int) -> [HourWeather] {
            guard let weathers = hourlyWeathers else { return [] }
            guard let roundedCurrentDate = roundDownToNearestHour(Date()) else { return [] }
            
            return Array(
                weathers.filter {
                    $0.date >= roundedCurrentDate
                }.prefix(count)
            )
        }
        
        // Round down to nearest hour (including current hour).
        private func roundDownToNearestHour(_ date: Date) -> Date? {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            return calendar.date(from: components)
        }
}

#Preview {
    WeatherView(locationManager: LocationManager(locationFetcher: CLLocationManager()))
}
