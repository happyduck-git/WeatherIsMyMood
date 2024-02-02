//
//  WeatherAppIntent.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/19/24.
//

import WidgetKit
import AppIntents

@available(iOS 17.0, *)
struct WeatherAppIntent: WidgetConfigurationIntent {
    static var intentClassName: String = "WeatherAppIntentClass"
    
    static var title: LocalizedStringResource = "WeatherAppIntentTitle"
   
    @Parameter(title: "Personal Quote")
    var quote: String?
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
