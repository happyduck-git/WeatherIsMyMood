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
import Combine

struct WeatherView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var storageManager: FirestoreManager
    private let weatherService = WeatherService.shared
    
    @State private var loadStaus: LoadStatus = .loaded
    @State private var aqiList: [AQList] = []
    @State private var isFirstLoading = true
    @State private var isLoading = false
    @State private var weather: Weather?
    @State private var hourlyWeatherData: [HourWeather] = []
    @State private var attribution: WeatherAttribution?
    @State private var location: CLLocation?
    @State private var cityName: String = ""
    @State private var searchedCityName: String = ""
    @State private var locationFound: Bool = true
    private var errorPublisher = PassthroughSubject<Error, Never>()
    
    //MARK: - UI
    var body: some View {
        NavigationView {
            self.content
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
            await self.fetchData()
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .onChange(of: self.searchedCityName, perform: { _ in
            self.locationFound = true
        })
        .onChange(of: self.locationFound, perform: {
            if !$0 {
                self.isLoading = false
            }
        })
        .onReceive(self.errorPublisher) {
            self.loadStaus = .failed($0)
        }
        .onReceive(self.locationManager.$error) {
            if let err = $0 {
                self.loadStaus = .failed(err)
            }
        }
    }
    
}

//MARK: - UI Contents
extension WeatherView {
    
    @ViewBuilder
    private var content: some View {
        switch self.loadStaus {
        case .notRequested:
            notRequestedView
        case .loaded:
            loadedView
        case let .failed(error):
            errorView(error)
        }
    }
    
    private var notRequestedView: some View {
        Text("")
    }
    
    private var loadedView: some View {
        ZStack {
            mainView
            if isLoading {
                LoadingView(filename: "sun_color")
            }
        }
    }
    
    private func errorView(_ err: Error) -> some View {
        ErrorView(error: err) {
            self.isLoading = true
            Task {
                await self.fetchData()
            }
        }
    }
    
    private var mainView: some View {
        ScrollView(.vertical) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                Section {
                    if !locationFound {
                        Text("Location not found.\nPlease search other location!")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red.opacity(0.9))
                            .padding()
                    }
                    
                    if weather != nil {
                        CityWeatherView(weather: $weather,
                                        cityName: $cityName,
                                        aqList: $aqiList)
                        .padding(.vertical, 10)
                        
                        HourlyForcastView(hourWeatherList: self.$hourlyWeatherData)
                        
                        TenDayForcastView(weather: $weather)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        
                        //NOTE: Need to be delivered in the next version.
                        //                        AirQualityView(aqList: $aqiList)
                        
                        HourlyPrecipitationChartView(hourWeatherList: self.$hourlyWeatherData)
                        
                        DataAttributionView(weatherAttribution: attribution)
                            .padding(EdgeInsets(top: 30, leading: 0, bottom: 10, trailing: 0))
                    } else {
                        Color(ColorConstants.main)
                            .ignoresSafeArea()
                    }
                } header: {
                    
                    SearchView(searchCity: $searchedCityName) {
                        Task {
                            await self.updateLocationStatus(to: searchedCityName)
                        }
                        
                    } backToCurrentLocation: {
                        searchedCityName = ""
                        Task {
                            await self.backToCurrentLocation()
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

//MARK: - Fetch necessary data
extension WeatherView {
    
    private func fetchData() async {
        self.location = locationManager.currentLocation
        
        if let location = self.location {
#if DEBUG
            print("Loc on weatherView: \(location.coordinate.latitude)")
#endif
            do {
                async let weather = weatherService.weather(for: location)
                async let attribution = weatherService.attribution
                async let cityName = locationManager.cityName(at: location)
                
                self.weather = try await weather
                self.attribution = try await attribution
                self.hourlyWeatherData = self.filterHours(of: self.weather?.hourlyForecast, count: 24)
                
                if let unwrappedCityName = await cityName {
                    self.cityName = unwrappedCityName
                } else {
                    self.locationFound = false
                }
                
                self.isLoading = false
            }
            catch {
                self.errorPublisher.send(error)
                self.isLoading = false
                print("Catched weather error: \(error)")
            }
        } else {
            print("Current location found to be nil!")
        }
    }
    
    private func updateLocationStatus(to city: String) async {
        if !city.isEmpty {
            self.isLoading = true
            let loc = await self.locationManager.location(forCity: city, geocoder: CLGeocoder())
            guard let loc else {
                self.locationFound = false
                return
            }
            self.locationFound = true
            self.locationManager.currentLocation = loc
        }
    }
    
    private func backToCurrentLocation() async {
        await self.locationManager.requestOnTimeLocation()
        await self.updateLocationStatus(to: self.locationManager.cityName ?? "Seoul")
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
    WeatherView()
}
