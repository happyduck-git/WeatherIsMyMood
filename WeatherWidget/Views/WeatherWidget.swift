//
//  WeatherWidget.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import SwiftUI
import WeatherKit
import WidgetKit
import FirebaseCore
import CoreLocation

struct WeatherWidget: Widget {
    
    private let locationManager: LocationManager = LocationManager(locationFetcher: CLLocationManager())
    private let cacheManager: NSCacheManager = NSCacheManager()
    private let firestoreManager: FirestoreManager = FirestoreManager()
    
    public var body: some WidgetConfiguration {
        self.makeWidgetConfiguration()
    }
    
    func makeWidgetConfiguration() -> some WidgetConfiguration {
        
#if os(iOS)
        if #available(iOS 17.0, *) {
      
            return AppIntentConfiguration(kind: "WeatherWidget",
                                          intent: WeatherAppIntent.self,
                                          provider: WeatherTimelineProvider(locationManager: self.locationManager,
                                                                            cacheManager: self.cacheManager,
                                                                            firestoreManager: self.firestoreManager)) { entry in
                WeatherEntryView(entry: entry)
            }.supportedFamilies(supportedFamilies)
            
        } else {
            return IntentConfiguration(kind: "WeatherWidget",
                                       intent: WeatherSelectionIntent.self,
                                       provider: SiriKitIntentProvider(locationManager: self.locationManager,
                                                                       cacheManager: self.cacheManager,
                                                                       firestoreManager: self.firestoreManager)) { entry in
                WeatherEntryView(entry: entry)
            }.supportedFamilies(supportedFamilies)
        }
#endif
    }
    
    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        [.systemSmall, .systemMedium]
        #endif
    }
}

struct WeatherEntryView: View {
    var entry: WeatherEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        if let weather = entry.weather {
            
            switch family {
                
            case .systemSmall:
                
                VStack(alignment: .leading) {
                    self.makeTopSmallView(weather: weather, fontSize: (14, 13))
                    self.makeTemparatureView(weather: weather, fontSize: (19, 10))
                    self.makeWeatherInfoListView(weather: weather, fontSize: 12)
                    
                    Divider()
                   
                    Text(entry.quote)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 11))
                }
                .widgetPadding()
                .widgetBackground(with: entry.image)
                
            case .systemMedium:
                HStack {
                    VStack(alignment: .leading) {
                        self.makeTopView(weather: weather, fontSize: (16, 15))
                        self.makeTemparatureView(weather: weather, fontSize: (23, 14))
                        self.makeWeatherInfoListView(weather: weather, fontSize: 14)
                    }
                    
                    Divider()
                   
                    Text(entry.quote)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 15))
                }
                .widgetPadding()
                .widgetBackground(with: entry.image)
                
            default:
                Text("Stay tuned!")
                    .widgetPadding()
                    .widgetBackground(with: entry.image)
            }
        } else {
            VStack(alignment: .leading) {
                Text(WidgetConstants.loadingError)
                
                Spacer()
               
                Text(entry.quote)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 11))
            }
            .widgetPadding()
            .widgetBackground(with: entry.image)
        }

        
    }
    
    private enum WeatherContent: CaseIterable {
        case precipitation
        case humidity
        case wind
        
        var displayText: String {
            switch self {
            case .precipitation:
                WidgetConstants.precipitation
            case .humidity:
                WidgetConstants.humidity
            case .wind:
                WidgetConstants.wind
            }
        }
        
        var unit: String {
            switch self {
            case .precipitation:
                WidgetConstants.precipitationUnit
            case .humidity:
                WidgetConstants.humidityUnit
            case .wind:
                WidgetConstants.windUnit
            }
        }
    }
    
}

//MARK: - Private functions for making widget views.
extension WeatherEntryView {
    private func makeTopSmallView(
        weather: Weather,
        fontSize: (cityName: CGFloat, condition: CGFloat)
    ) -> some View {
        
        HStack(alignment: .center) {
            Text(entry.cityName)
                .fontWeight(.semibold)
                .font(.system(size: fontSize.cityName))
            Spacer()
            Image(systemName: weather.currentWeather.symbolName)
                .resizable()
                .frame(width: 13, height: 13)
                .scaledToFit()
        }
        
    }
    
    private func makeTopView(
        weather: Weather,
        fontSize: (cityName: CGFloat, condition: CGFloat)
    ) -> some View {
        
        HStack(alignment: .bottom) {
            Text(entry.cityName)
                .fontWeight(.semibold)
                .font(.system(size: fontSize.cityName))
            Spacer()
            Image(systemName: weather.currentWeather.symbolName)
                .resizable()
                .frame(width: 15, height: 15)
                .scaledToFit()
        }
        
    }
    
    private func makeTemparatureView(
        weather: Weather,
        fontSize: (title: CGFloat, subTitle: CGFloat)
    ) -> some View {
        return HStack(alignment: .bottom) {
            Text("\(weather.currentWeather.temperature.value.convertToTempFormat(decimal: 1))".addTemparatureUnit())
                .fontWeight(.bold)
                .font(.system(size: fontSize.title))
            Spacer()
            VStack(alignment: .trailing) {
                Text(
                    "\(WidgetConstants.highest): \(weather.dailyForecast.forecast.first?.highTemperature.value.convertToTempFormat(decimal: 1) ?? "0.0")".addTemparatureUnit()
                )
                    .fontWeight(.medium)
                    .font(.system(size: fontSize.subTitle))
                Text("\(WidgetConstants.lowest): \(weather.dailyForecast.forecast.first?.lowTemperature.value.convertToTempFormat(decimal: 1) ?? "0.0")".addTemparatureUnit())
                    .fontWeight(.medium)
                    .font(.system(size: fontSize.subTitle))
            }
            
            
        }
        .padding(.vertical, 1)
        .frame(maxWidth: .infinity)
    }
    
    private func makeWeatherInfoListView(
        weather: Weather,
        fontSize: CGFloat
    ) -> some View {
        
        return VStack(alignment: .leading) {
            ForEach(WeatherContent.allCases, id: \.displayText) { content in
                HStack {
                    Text(content.displayText)
                        .fontWeight(.semibold)
                        .font(.system(size: fontSize))
                    Spacer()
                    
                    self.makeWeatherInfoView(of: content, weather: weather, fontSize: fontSize)
                }
                .frame(maxWidth: .infinity)
            }
            
        }
        .background {
            Color.white.opacity(0.2)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
    
    private func makeWeatherInfoView(
        of content: WeatherContent,
        weather: Weather,
        fontSize: CGFloat
    ) -> some View {
        
        switch content {
        case .precipitation:
            return Text("\(weather.currentWeather.precipitationIntensity.value.convertToTempFormat(decimal: 2)) \(content.unit)")
                .font(.system(size: fontSize))
        case .humidity:
            return Text("\(weather.currentWeather.humidity.convertToTempFormat(decimal: 2)) \(content.unit)")
                .font(.system(size: fontSize))
        case .wind:
            return Text("\(weather.currentWeather.wind.speed.value.convertToTempFormat(decimal: 2)) \(content.unit)")
                .font(.system(size: fontSize))
        }
    }
}

extension View {
    @ViewBuilder
    func widgetBackground(with imageData: Data?) -> some View {
        
        if let imageData = imageData,
           let image = UIImage(data: imageData) {
            if #available(iOS 17.0, *) {
                containerBackground(for: .widget) {
                    Image(uiImage: image)
                        .resizable(resizingMode: .stretch)
                        .frame(width: 500, height: 500)
                        .opacity(0.6)
                }
                
            } else {
                background {
                    Image(uiImage: image)
                        .resizable(resizingMode: .stretch)
                        .frame(width: 360, height: 360)
                        .opacity(0.6)
                }
            }
            
        } else {
            if #available(iOS 17.0, *) {
                containerBackground(for: .widget) { Color.white }
            } else {
                background { Color.white }
            }
        }
        
    }
        
    func widgetPadding() -> some View {
        if #available(iOS 17.0, *) {
            return self.padding(.zero)
        }
        else {
            return self.padding(.all)
        }
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(),
                 cityName: "Seoul",
                 weather: nil,
                 image: nil,
                 quote: "Hello")
}

