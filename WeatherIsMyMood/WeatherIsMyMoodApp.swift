//
//  WeatherIsMyMoodApp.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/9/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
    }
}

@main
struct WeatherIsMyMoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Task {
                        await ATTrackingManager.requestTrackingAuthorization()
                    }
                }
                .onAppear {
                    switch ATTrackingManager.trackingAuthorizationStatus {
                    case .authorized:
                        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
                    default:
                        return
                    }
                }
        }
    }
}
