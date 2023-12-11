//
//  DecorateView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct DecorationView: View {
    @StateObject private var locationManager = LocationManager()
    private let weatherService = WeatherService.shared
    @State private var weather: Weather?
    @State private var condition: WeatherCondition = .clear
    
    private let numberOfColumns = 3
    @State private var weatherIcons: [String] = ["clear_cloudy", "clear_cloudy"]
    @State private var otherIcons: [String] = ["clear_cloudy", "clear_cloudy"]
    
    var body: some View {
        VStack {
            Text("Preview")
                .fontWeight(.bold)
                .frame(alignment: .leading)
            
            DynamicIslandPreviewView(weather: $weather)
            
            Text("Weather")
                .fontWeight(.bold)
                .frame(alignment: .leading)
            
            self.emojiCollectionView(self.weatherIcons)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            
            Text("Others")
                .fontWeight(.bold)
                .frame(alignment: .leading)
            
            self.emojiCollectionView(self.otherIcons)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            
            Text(condition.rawValue)
            
            self.saveButtonView()
        }
        .background {
            AppColors.main
                .ignoresSafeArea()
        }
        .task(id: locationManager.currentLocation) {
            if let location = locationManager.currentLocation {
                do {
                    self.weather = try await weatherService.weather(for: location)
                }
                catch {
                    print(error)
                }
            }
        }
        .onChange(of: self.weather) { _, newValue in
            if let newValue {
                condition = newValue.currentWeather.condition
            }
        }
    }
    
}

extension DecorationView {
    
    private func saveButtonView() -> some View {
        Button {
            //TODO: Save as Dynamic island
            
        } label: {
            Text("Save")
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
        .background {
            Color.blue.opacity(0.8)
        }
        .foregroundStyle(.white)
        .clipShape(Capsule(style: .continuous))
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
    }
    
    private func emojiCollectionView(_ icons: [String]) -> some View {
        return  ScrollView(.vertical, showsIndicators: false) {
            let numberOfRows = (icons.count + 2) / numberOfColumns
            
            ForEach(0..<numberOfRows, id: \.self) { row in
                HStack {
                    ForEach(0..<numberOfColumns, id: \.self) { col in
                        let index = row * numberOfColumns + col
                        
                        if index < icons.count {
                            EmojiViewCell(emojiName: icons[index])
                        } else {
                            EmojiViewCell(emojiName: "")
                        }
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    DecorationView()
}


