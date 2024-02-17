//
//  CityCurrentWeatherView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit
import UIKit.UIImage
import PDFKit
import CoreLocation

struct CityCurrentWeatherView: View {
    
    let fireStoreManager: FirestoreManager
    
    //MARK: - Properties
    @Binding var weather: Weather?
    @Binding var cityName: String
    
    @State var previousWeather: Weather?
    @State var weatherImage: UIImage?
    @State var isFirstLoad = true
    
    @State private var weatherComponents: [CityWeatherComponent] = []
    
    //MARK: - View
    var body: some View {
        
        ZStack {
            if let weatherImage {
                Image(uiImage: weatherImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.5)
            } else {
                Circle()
                    .fill(.clear)
                    .background {
                        LinearGradient(
                            colors: [.clear,
                                     .white.opacity(0.6),
                                     .clear],
                            startPoint: .top,
                            endPoint: .bottomTrailing
                        )
                        
                        .clipShape(Circle())
                    }
            }
            
            VStack {
                TitleView(cityName: $cityName,
                          weather: $weather)
                VStack {
                    VStack(alignment: .leading) {
                        ForEach(self.weatherComponents, id: \.title) {
                            self.weatherComponentsView(title: $0.title,
                                                       icon: $0.icon,
                                                       color: $0.iconColor,
                                                       value: $0.value)
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                    HStack {
                        SunStatusTimeView(status: .sunrise,
                                          weather: $weather)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                        SunStatusTimeView(status: .sunset,
                                          weather: $weather)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                    }
                }
                
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.4))
                }
                
            }
            .task(id: self.weather) {
                if isFirstLoad {
                    self.previousWeather = self.weather
                    self.weatherComponents = self.updateWeatherComponents(with: self.weather)
                    Task {
                        self.weatherImage = await self.fetchBackgroundImage(self.weather)
                    }
                    self.isFirstLoad = false
                }
                
            }
            .onChange(of: self.weather) { newWeather in
                
                if shouldUpdateWeather(prev: previousWeather, new: newWeather) {
                    self.previousWeather = newWeather
                    self.weatherComponents = self.updateWeatherComponents(with: newWeather)
                    Task {
                        self.weatherImage = await self.fetchBackgroundImage(newWeather)
                    }
                }
            }
            
        }
        
    }
}

//MARK: - UI Components
extension CityCurrentWeatherView {
    private func weatherComponentsView(title: String,
                                       icon: String,
                                       color: Color,
                                       value: String) -> some View {
        
        HStack {
            Image(systemName:icon)
                .foregroundStyle(color)
            Text(title)
            Divider()
                .frame(height: 10)
            Text(value)
                .fontWeight(.semibold)
                .frame(alignment: .trailing)

        }
        
    }
}

//MARK: - Fetch data
extension CityCurrentWeatherView {
    
    private func fetchBackgroundImage(_ weather: Weather?) async -> UIImage {
        let defaultImage = UIImage(resource: .weatherMorningBright)
        
        guard let weather else {
            return defaultImage
        }
        
        do {
            let condition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
            let data = try await fireStoreManager.fetchBackground(condition)
            if let image = UIImage(data: data) {
                return image
            } else {
                return defaultImage
            }
            
        } catch {
            print(error)
            return defaultImage
        }
    }
    
    private func updateWeatherView(with newWeather: Weather?) async throws {
        if let weather = newWeather {
            self.previousWeather = weather
            
            let newCondition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
            
            let data = try await fireStoreManager.fetchBackground(newCondition)
            
            guard let image = UIImage(data: data) else {
                self.weatherImage = UIImage(resource: .weatherMorningBright)
                return
            }
            self.weatherImage = image
        }
        else {
            //TODO: `newWeather found to be nil` handling.
        }
    }
    
    private func updateWeatherComponents(with newWeather: Weather?) -> [CityWeatherComponent] {
        return [.feelsLike(weather: newWeather),
                .humidity(weather: newWeather),
                .uvIndex(weather: newWeather)]
    }
}

//MARK: - Data processing
extension CityCurrentWeatherView {
    private func shouldUpdateWeather(prev: Weather?, new: Weather?) -> Bool {
        let oldTemp = prev?.currentWeather.temperature.value ?? 0.0
        let newTemp = new?.currentWeather.temperature.value ?? 0.0
        
        let condA = abs(oldTemp.rounded(.up) - newTemp.rounded(.up)) >= 1
        let condB = prev?.currentWeather.condition != new?.currentWeather.condition
        let result = condA || condB
        
        return result
    }
}

#Preview {
    WeatherView(locationManager: LocationManager(locationFetcher: CLLocationManager()),
                storageManager: FirestoreManager())
}
