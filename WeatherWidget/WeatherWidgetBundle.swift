//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by HappyDuck on 12/12/23.
//

import WidgetKit
import SwiftUI
import FirebaseCore

@main
struct WeatherWidgetBundle: WidgetBundle {
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }

    var body: some Widget {
//        DemoWidget()
        WeatherWidget()
        #if canImport(ActivityKit)
        WeatherLiveActivityWidget()
        #endif
    }
}
