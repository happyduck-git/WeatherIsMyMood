//
//  DecorateView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct DecorationView: View {
    
    @State private var isFirstLoading = true
    @State private var isLoading = false
    @State private var isOn = false
    
    @StateObject private var locationManager = LocationManager()
    private let weatherService = WeatherService.shared
    private let storageManager = FirestoreManager.shared
    
    @State private var weather: Weather?
    @State private var previousWeather: Weather?
    @State private var condition: WeatherCondition = .clear
    
    private let numberOfColumns = 4
    @State private var weatherIcons: [Data] = []
    @State private var otherIcons: [Data] = []
    @State private var selectedIcon: Data?
    
    var body: some View {
        ZStack {
            VStack {
                    
                EnableToggleView(isOn: $isOn,
                                 weather: $weather,
                                 selectedIcon: $selectedIcon)
                
                Text("Preview")
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                DynamicIslandPreviewView(weather: $weather,
                                         selectedIcon: $selectedIcon)
                
                Text("Weather")
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
                self.emojiCollectionView(self.weatherIcons)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                
                Text("Others")
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                
                self.emojiCollectionView(self.otherIcons)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
               
            }
            .background {
                AppColors.main
                    .ignoresSafeArea()
            }
                    
            if isLoading {
                LoadingView()
            }
        }
        .task(id: locationManager.currentLocation) {
            if let location = locationManager.currentLocation {
                do {
                    self.weather = try await weatherService.weather(for: location)
                    if self.isFirstLoading {
                        self.isFirstLoading = false
                    } else {
                        self.previousWeather = self.weather
                    }
                }
                catch {
                    print(error)
                }
            }
        }
        .onChange(of: self.weather, perform: { newWeather in
            if self.previousWeather?.currentWeather.condition != newWeather?.currentWeather.condition {
                self.isLoading = true
                
                if let newWeather {
                    Task {
                        do {
                            try await self.updateWeatherData(newWeather)
                            self.previousWeather = newWeather
                            self.isLoading = false
                        }
                        catch {
                            print("Error fetching weather icons -- \(error)")
                        }
                    }
                }
            }
        })
    }
    
}

extension DecorationView {
    private func updateWeatherData(_ weather: Weather) async throws {
        let condition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
        async let others = storageManager.fetchOtherIcons(maxResults: 20).data
        async let weathers = storageManager.fetchWeatherIcons(condition)
        
        self.otherIcons = try await others
        self.weatherIcons = try await weathers
        self.isLoading = false
    }
}

extension DecorationView {

    private func emojiCollectionView(_ icons: [Data]) -> some View {
        return  ScrollView(.vertical, showsIndicators: false) {
            let numberOfRows = (icons.count + 2) / numberOfColumns
            
            ForEach(0..<numberOfRows, id: \.self) { row in
                HStack {
                    ForEach(0..<numberOfColumns, id: \.self) { col in
                        let index = row * numberOfColumns + col
                        
                        if index < icons.count {
                            
                            EmojiViewCell(emojiData: icons[index])
                                .onTapGesture {
                                    self.selectedIcon = icons[index]
                                    print("Tapped Row: \(row), Col: \(col)")
                                }
                        }
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(minWidth: UIScreen.screenWidth - 80)
        }
    }
}

//#Preview {
//    DecorationView()
//}


