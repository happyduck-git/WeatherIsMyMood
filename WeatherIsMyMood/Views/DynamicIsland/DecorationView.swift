//
//  DecorateView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct DecorationView: View {
    
    @AppStorage("isDynamicIslandOn") private var isOn = false
    @AppStorage("widgetBGColors") private var savedBgColor: Color = .widgetBG
    @AppStorage("widgetTextColors") private var savedTextColor: Color = .primary
    @AppStorage("widgetIcon") private var savedIcon: Data?
    @AppStorage("widgetSystemSetting") private var isSystemSetting: Bool = true
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var storageManager: FirestoreManager
    private let weatherService = WeatherService.shared
    
    @State private var loadStaus: LoadStatus = .notRequested
    @State private var isFirstLoading: Bool = true
    @State private var isLoading: Bool = false
    @State private var settingInProgress: Bool = false
    @State private var isFirstAppear: Bool = true
    @State private var weather: Weather?
    @State private var previousWeather: Weather?
    @State private var condition: WeatherCondition = .clear
    @State private var weatherIcons: [Data] = []
    @State private var otherIcons: [Data] = []
    @State private var newBgColor: Color = .widgetBG
    @State private var newTextColor: Color = .primary
    @State private var newIcon: Data?
    @State private var updateNeeded: Bool = false
    @State private var isConfirmed: Bool = true
    
    var body: some View {
        NavigationView {
            self.content
            .toolbarBackground(Color(ColorConstants.main), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(.logo)
                        .resizable()
                        .frame(width: 40, height: 50, alignment: .bottom)
                        .aspectRatio(contentMode: .fit)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.isConfirmed = true
                        self.updateNeeded = false
                        self.settingInProgress = true
                        self.submitNewWidgetAttributes()
                    } label: {
                        Text(DecoConstants.change)
                    }
                    .foregroundStyle(self.updateNeeded ? .blue : .gray)
                    .disabled(self.updateNeeded ? false : true)
                }
            }
        }
        .onAppear {
            if self.isFirstAppear {
                self.newBgColor = self.savedBgColor
                self.newTextColor = self.savedTextColor
                self.newIcon = self.savedIcon
                self.isFirstAppear = false
            }
        }
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
                    self.loadStaus = .loaded
                }
                catch {
                    print("Error fething weather from location -- \(error)")
                }
            } else {
                print("Location found to be nil -- DecorationView")
            }
        }
        .onChange(of: self.weather) { newWeather in
            self.updateWeather(with: newWeather)
        }
        .onChange(of: self.updateNeeded) {
            if $0 {
                self.isConfirmed = false
            }
        }
        .onChange(of: self.settingInProgress) {
            if $0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.settingInProgress = false
                }
            }
        }
        .onReceive(self.locationManager.$error) {
            if let err = $0 {
                self.loadStaus = .failed(err)
            }
        }
    }
    
    private func updateWeather(with newWeather: Weather?) {
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
    }
}

extension DecorationView {
    private func updateWeatherData(_ weather: Weather) async throws {
        let condition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
        async let others = storageManager.fetchOtherIcons(maxResults: 20).data
        async let weathers = storageManager.fetchWeatherIcons(condition)
        
        self.otherIcons = try await others
        self.weatherIcons = try await weathers
        
        // Check if there is no saved icon, assign the first icon.
        if self.savedIcon == nil {
            self.savedIcon = self.weatherIcons.first
        }
    }
    
    private func submitNewWidgetAttributes() {
        self.savedIcon = self.newIcon
        self.savedBgColor = self.newBgColor
        self.savedTextColor = self.newTextColor
    }
}

//MARK: - UI Contents
extension DecorationView {
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
    
    var notRequestedView: some View {
        Text("")
    }
    
    var loadedView: some View {
        ZStack {
            mainView
            if isLoading {
                LoadingView(filename: "sun_color")
            }
            if settingInProgress {
                LoadingView(filename: "setting")
            }
        }
    }
    
    private func errorView(_ err: Error) -> some View {
        ErrorView(error: err) {
            self.isLoading = true
        }
    }
    
    private var mainView: some View {
        return ScrollView {
            
            LiveActivityToggleView(isSystemSetting: self.$isSystemSetting,
                                   isOn: self.$isOn,
                                   weather: self.$weather,
                                   selectedIcon: self.$savedIcon,
                                   selectedColor: self.$savedBgColor,
                                   selectedTextColor: self.$savedTextColor,
                                   isConfirmed: self.$isConfirmed)
            
            Text(DecoConstants.preview)
                .fontWeight(.bold)
                .frame(alignment: .leading)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            Text(WeatherConstants.previewDescription)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))

            LiveActivityPreviewView(weather: self.$weather,
                                    selectedColor: self.$savedBgColor,
                                    selectedTextColor: self.$savedTextColor,
                                    selectedIcon: self.$savedIcon,
                                    newBgColor: self.$newBgColor,
                                    newTextColor: self.$newTextColor,
                                    newIcon: self.$newIcon,
                                    updateNeeded: self.$updateNeeded,
                                    isSystemColor: self.$isSystemSetting)
            
            HStack{
                SectionTitleView(section: .weatherIcons)
                    .frame(width: 200)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                Spacer()
            }
            
            self.emojiCollectionView(self.weatherIcons)
            
            HStack{
                SectionTitleView(section: .emojis)
                    .frame(width: 200)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
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
                                        self.newIcon = data[index]
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

#Preview {
    DecorationView()
}


