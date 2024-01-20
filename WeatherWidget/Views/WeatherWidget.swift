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
        [.systemSmall]
        #endif
    }
}

struct WeatherEntryView: View {
    var entry: WeatherEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        switch family {
            
        case .systemSmall:
            
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.system(size: 13))
                HStack(alignment: .bottom) {
                    Text(entry.weather?.currentWeather.temperature.formatted() ?? "0.0")
                        .font(.system(size: 18))
                    Text("H: \(entry.weather?.dailyForecast.forecast.first?.highTemperature.formatted() ?? "0.0")")
                        .font(.system(size: 13))
                    Text("L: \(entry.weather?.dailyForecast.forecast.first?.lowTemperature.formatted() ?? "0.0")")
                        .font(.system(size: 13))
                }
                
                VStack(alignment: .leading) {
                    ForEach(WeatherContent.allCases, id: \.displayText) { content in
                        HStack {
                            Text(content.displayText)
                                .fontWeight(.semibold)
                                .font(.system(size: 12))
                            Spacer()
                            Text(content.unit)
                                .font(.system(size: 12))
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
                    .font(.system(size: 11))
            }
            .widgetBackground(with: entry.image)
            
        default:
            Text("Stay tuned!")
                .widgetBackground(with: entry.image)
        }
        
    }
    
    private enum WeatherContent: CaseIterable {
        case condition
        case precipitation
        case humidity
        case wind
        
        var displayText: String {
            switch self {
            case .condition:
                WidgetConstants.condition
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
            case .condition:
                String()
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
                 Image(uiImage: image).opacity(0.7)
//                 Color.orange.opacity(0.6)
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

