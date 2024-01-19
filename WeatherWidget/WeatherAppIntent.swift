//
//  WeatherAppIntent.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import WidgetKit
import AppIntents

@available(iOS 16.0, *)
struct WeatherAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Personal Quote"
   
    @Parameter(title: WeatherAppIntent.title)
    var quote: String?
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
