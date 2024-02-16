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

struct CityCurrentWeatherView: View {
    
    let fireStoreManager: FirestoreManager
    
    //MARK: - Properties
    @Binding var weather: Weather?
    @Binding var cityName: String
    
    @State var previousWeather: Weather?
    @State var weatherImage: UIImage?
    @State var isFirstLoad = true
    
    //MARK: - View
    var body: some View {
        if let weather {
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
                    
                    HStack {
                        SunStatusTimeView(status: .sunrise,
                                          weather: $weather)
                            .padding()
                        SunStatusTimeView(status: .sunset,
                                          weather: $weather)
                            .padding()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.4))
                    }
                    
                }
            }
            .task(id: self.weather) {
                
                if isFirstLoad {
                    Task {
                        do {
                            self.previousWeather = self.weather
                            
                            let condition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
                            let data = try await fireStoreManager.fetchBackground(condition)
                            if let image = UIImage(data: data) {
                                self.weatherImage = image
                            } else {
                                self.weatherImage = UIImage(resource: .weatherMorningBright)
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                    self.isFirstLoad = false
                }
                
            }
            .onChange(of: self.weather, perform: { newWeather in
               
                if shouldUpdateWeather(prev: previousWeather, new: newWeather) {
                    Task {
                        do {
                            self.previousWeather = newWeather
                            
                            let condition = WeatherCondition.getWeatherIconName(of: newWeather?.currentWeather.condition.rawValue ?? "sunny")
                            let data = try await fireStoreManager.fetchBackground(condition)
                            if let image = UIImage(data: data) {
                                self.weatherImage = image
                            } else {
                                self.weatherImage = UIImage(resource: .weatherMorningBright)
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                }
            })
            
        }
            
    }
}

extension CityCurrentWeatherView {
    private func shouldUpdateWeather(prev: Weather?, new: Weather?) -> Bool {
        let oldTemp = prev?.currentWeather.temperature.value ?? 0.0
        let newTemp = new?.currentWeather.temperature.value ?? 0.0
        
        let condA = abs(oldTemp.rounded(.up) - newTemp.rounded(.up)) >= 1
        let condB = prev?.currentWeather.condition != new?.currentWeather.condition
        let result = condA || condB
        
        return result
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
}
