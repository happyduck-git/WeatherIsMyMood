//
//  DecorateView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct DecorationView: View {
    
    @ObservedObject private var locationManager: LocationManager
    
    @State private var isFirstLoading = true
    @State private var isLoading = false
    @AppStorage("isDynamicIslandOn") private var isOn = false
    
    private let weatherService = WeatherService.shared
    private let storageManager = FirestoreManager()
    
    @State private var weather: Weather?
    @State private var previousWeather: Weather?
    @State private var condition: WeatherCondition = .clear
    
    @State private var weatherIcons: [Data] = []
    @State private var otherIcons: [Data] = []
    @State private var selectedIcon: Data?
    
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
        
        .onAppear(perform: {
            print("DecorationView appeared")
        })
        .onDisappear(perform: {
            print("DecorationView disappeared")
        })
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
                    print("Error fething weather from location -- \(error)")
                }
            } else {
                print("Location found to be nil -- DecorationView")
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
    }
}

extension DecorationView {
    
    private func makeScrollView() -> some View {
        return ScrollView {
            
            EnableToggleView(isOn: $isOn,
                             weather: $weather,
                             selectedIcon: $selectedIcon)
            
            Text(DecoConstants.preview)
                .fontWeight(.bold)
                .frame(alignment: .leading)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            DynamicIslandPreviewView(weather: $weather,
                                     selectedIcon: $selectedIcon)
            
            
            HStack {
                Text(DecoConstants.weather)
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                Spacer()
            }
            
            self.emojiCollectionView(self.weatherIcons)
            
            HStack {
                Text(DecoConstants.others)
                    .fontWeight(.bold)
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                Spacer()
            }
            
            self.emojiCollectionView(self.otherIcons)
            
        }
        .scrollIndicators(.never)
        .background {
            Color(ColorConstants.main)
                .ignoresSafeArea()
        }
    }
    
    private func emojiCollectionView(_ icons: [Data]) -> some View {

        let rows = 2
        let columns = (icons.count + 2) / rows
        return makeCollectionView(direction: .horizontal,
                                  row: 2,
                                  column: columns,
                                  data: icons)
   
        /* Horizontal */
        /*
        let columns = 4
        let rows = (icons.count + 2) / columns
        return makeCollectionView(direction: .vertical,
                                  row: rows,
                                  column: columns,
                                  data: icons)
        */

    }
    
    private func makeCollectionView(direction: Axis.Set, row: Int, column: Int, data: [Data]) -> some View {

        return ScrollView(direction) {
            VStack(alignment: .leading) {
                ForEach(0..<row, id: \.self) { row in
                    HStack {
                        ForEach(0..<column, id: \.self) { col in
                            let index = row * column + col
                            
                            if index < data.count {
                                
                                EmojiViewCell(emojiData: data[index])
                                    .onTapGesture {
                                        self.selectedIcon = data[index]
                                    }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        
    }
}



