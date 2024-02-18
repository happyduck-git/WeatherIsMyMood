//
//  ContentView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import SwiftUI
import WeatherKit
import CoreLocation
import Alamofire

struct WeatherView: View {
    
    @ObservedObject private var locationManager: LocationManager
    private let storageManager: FirestoreManager
    private let networkManager: NetworkManager = NetworkManager(alamofire: Session())
    @State private var aqi: Int?
    
    @State private var isFirstLoading = true
    @State private var isLoading = false
    
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State var hourlyWeatherData: [HourWeather] = []
    
    @State var attribution: WeatherAttribution?
    @State private var cityName: String = ""
    @State private var searchedCityName: String = ""
    @State var locationFound: Bool = true
    
    init(locationManager: LocationManager,
         storageManager: FirestoreManager) {
        self.locationManager = locationManager
        self.storageManager = storageManager
        #if DEBUG
        print("WeatherViewInit")
        #endif
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
            print("WeatherView appeared")
        }
        .task(id: locationManager.currentLocation) {

            if let location = locationManager.currentLocation {
                #if DEBUG
                print("Loc on weatherView: \(location.coordinate.latitude)")
                #endif
                do {
                    async let weather = weatherService.weather(for: location)
                    async let attribution = weatherService.attribution
                    async let cityName = locationManager.cityName(at: location)
                    // Temp comment out
//                    async let aqi = self.fetchAirQuality(location: location)
                    
                    self.weather = try await weather
                    self.attribution = try await attribution
                    if let unwrappedCityName = await cityName {
                        self.cityName = unwrappedCityName
                    } else {
                        self.locationFound = false
                    }
                    
                    self.hourlyWeatherData = self.filterHours(of: self.weather?.hourlyForecast, count: 24)
                    
//                    self.aqi = await aqi
                    
                    self.isLoading = false
                }
                catch {
                    print(error)
                }
            } else {
                print("Current location found to be nil!")
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
                        CityCurrentWeatherView(fireStoreManager: self.storageManager,
                                               weather: $weather,
                                               cityName: $cityName)
                        .padding(.vertical, 10)
                        
                        HourlyForcastView(hourWeatherList: self.hourlyWeatherData)
                        
                        TenDayForcastView(dayWeatherList: weather.dailyForecast.forecast)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        
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
                        
                    } backToCurrentLocation: {
                        searchedCityName = ""
                        Task {
                            await self.locationManager.requestOnTimeLocation()
                            self.updateLocationStatus(to: self.locationManager.cityName ?? "Seoul")
                        }
                    }
                    .frame(width: UIScreen.screenWidth)
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .background {
            Color(ColorConstants.main)
                .ignoresSafeArea()
        }
    }
}

extension WeatherView {
    private func fetchAirQuality(location: CLLocation) async -> Int {
        let lat = locationManager.currentLocation?.coordinate.latitude ?? 0
        let lon = locationManager.currentLocation?.coordinate.longitude ?? 0
        
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(EnvironmentConfig.openWeatherApiKey)"
        let result: Result<AirQuality, AFError> = await self.networkManager.fetchData(urlString: urlString)
        
        switch result {
        case .success(let success):
            return success.list.first?.main.aqi ?? 0
        case .failure(let failure):
            print("Error; -- \(failure)")
            return 0
        }
    }
}

extension WeatherView {
    private func updateLocationStatus(to city: String) {
        if !city.isEmpty {
            Task {
                let loc = await self.locationManager.location(forCity: city, geocoder: CLGeocoder())
                guard let loc else {
                    self.locationFound = false
                    return
                }
                self.locationFound = true
                self.locationManager.currentLocation = loc
            }
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
    WeatherView(locationManager: LocationManager(locationFetcher: CLLocationManager()),
                storageManager: FirestoreManager())
}
