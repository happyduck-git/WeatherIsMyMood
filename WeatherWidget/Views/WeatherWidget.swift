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

struct WeatherWidget: Widget {

    public var body: some WidgetConfiguration {
        self.makeWidgetConfiguration()
    }
    
    func makeWidgetConfiguration() -> some WidgetConfiguration {
#if os(iOS)
        if #available(iOS 17.0, *) {
      
            return AppIntentConfiguration(kind: "WeatherWidget",
                                          intent: WeatherAppIntent.self,
                                          provider: WeatherTimelineProvider()) { entry in
                WeatherEntryView(entry: entry)
            }.supportedFamilies(supportedFamilies)
            
        } else {
            return IntentConfiguration(kind: "WeatherWidget",
                                       intent: IntentIntent.self,
                                       provider: SiriKitIntentProvider()) { entry in
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
                
            case .systemSmall, .systemMedium:
                
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Text(entry.cityName)
                            .fontWeight(.semibold)
                            .font(.system(size: 13))
                        Spacer()
                        Text(weather.currentWeather.condition.rawValue)
                            .font(.system(size: 12))
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("\(weather.currentWeather.temperature.value.showDecimalTo(number: 1))".addTemparatureUnit())
                            .fontWeight(.bold)
                            .font(.system(size: 17))
                        
                        Text("H: \(weather.dailyForecast.forecast.first?.highTemperature.value.showDecimalTo(number: 1) ?? "0.0")".addTemparatureUnit())
                            .fontWeight(.medium)
                            .font(.system(size: 10))
                        Text("L: \(weather.dailyForecast.forecast.first?.lowTemperature.value.showDecimalTo(number: 1) ?? "0.0")".addTemparatureUnit())
                            .fontWeight(.medium)
                            .font(.system(size: 10))
                    }
                    .padding(.vertical, 1)
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.blue.opacity(0.1)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    
                    VStack(alignment: .leading) {
                        ForEach(WeatherContent.allCases, id: \.displayText) { content in
                            HStack {
                                Text(content.displayText)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 12))
                                Spacer()
                                
                                self.makeWeatherInfoView(of: content, weather: weather)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                    }
                    .background {
                        Color.white.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    
                    Divider()
                   
                    Text(entry.quote)
                        .frame(alignment: .center)
                        .font(.system(size: 11))
                }
                .widgetBackground(with: entry.image)
                
            default:
                Text("Stay tuned!")
                    .widgetBackground(with: entry.image)
            }
        } else {
            Text(WidgetConstants.loadingError)
                .widgetBackground(with: entry.image)
        }

        
    }
    
    private func makeWeatherInfoView(of content: WeatherContent, weather: Weather) -> some View {
        switch content {
        case .precipitation:
            Text("\(weather.currentWeather.precipitationIntensity.value.showTwoDecimalPlaces()) \(content.unit)")
                .font(.system(size: 12))
        case .humidity:
            Text("\(weather.currentWeather.humidity.showTwoDecimalPlaces()) \(content.unit)")
                .font(.system(size: 12))
        case .wind:
            Text("\(weather.currentWeather.wind.speed.value.showTwoDecimalPlaces()) \(content.unit)")
                .font(.system(size: 12))
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

extension View {
    func widgetBackground(with imageData: Data?) -> some View {
         if #available(iOS 17.0, *) {
             guard let imageData,
                   let image = UIImage(data: imageData) else {
                 return background {
                     Color.mint
                 }
             }
             
             return containerBackground(for: .widget) {
                 Image(uiImage: image)
                     .resizable(resizingMode: .stretch)
                     .frame(width: 360, height: 360)
                     .opacity(0.6)
             }
         } else {
             return background {
                 Color.green
             }
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

