//
//  WeatherWidget.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import SwiftUI
import WeatherKit
import WidgetKit

struct WeatherWidget: Widget {
    
    public var body: some WidgetConfiguration {
    
        self.makeWidgetConfiguration()
    }
    
   
    func makeWidgetConfiguration() -> some WidgetConfiguration {
#if os(iOS)
        if #available(iOS 17.0, *) {
      
            return AppIntentConfiguration(kind: WidgetConstants.widgetKind,
                                          intent: WeatherAppIntent.self,
                                          provider: WeatherTimelineProvider()) { entry in
                WeatherEntryView(entry: entry)
            }.supportedFamilies(supportedFamilies)
            
        } else {
            
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
            
            VStack {
                Text(entry.cityName)
                HStack {
                    Text(entry.weather?.currentWeather.temperature.formatted() ?? "0.0")
                    Text(entry.weather?.dailyForecast.forecast.first?.highTemperature.formatted() ?? "0.0")
                    Text(entry.weather?.dailyForecast.forecast.first?.lowTemperature.formatted() ?? "0.0")
                }
                
                List {
                    ForEach(WeatherContent.allCases, id: \.self) { content in
                        HStack {
                            Text(content.displayText)
                            Text(content.unit)
                        }
                        .padding(EdgeInsets(top: 5,
                                            leading: 5,
                                            bottom: 5,
                                            trailing: 5))
                        
                    }
                }
                
                Text(entry.quote)
            }
            
        default:
            Text("Stay tuned!")
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


