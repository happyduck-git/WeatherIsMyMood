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
import CoreLocation
import BackgroundTasks
import WeatherKit
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct WeatherIsMyMoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var locationManager: LocationManager = LocationManager(locationFetcher: CLLocationManager())
    private let storageManager: FirestoreManager = FirestoreManager()
    @StateObject private var coreStack = CoreDataStack()
    @State private var tasks: [UIBackgroundTaskIdentifier] = []
    
    var body: some Scene {

        if #available(iOS 17.0, *) {
            return WindowGroup {
                self.makeMainView(locationManager: self.locationManager,
                                  storageManager: self.storageManager)
            }
            .onChange(of: phase, initial: true) { _, newPhase in
                switch newPhase {
                case .background:
                    #if DEBUG
                    self.checkSavedBackgroundTasks()
                    #endif
                    
                    scheduleBgAppRefreshTask()
                default: break
                }
            }
            .backgroundTask(.appRefresh(BGTaskConstants.testId)) { _ in
                await self.handleAppRefreshTask()
            }
            
        } else {
            return WindowGroup {
                self.makeMainView(locationManager: self.locationManager,
                                  storageManager: self.storageManager)
            }
            .onChange(of: phase) { newPhase in
                switch newPhase {
                case .background:
                #if DEBUG
                    self.checkSavedBackgroundTasks()
                #endif
                    
                    scheduleBgAppRefreshTask()
                default: break
                }
            }
            .backgroundTask(.appRefresh(BGTaskConstants.testId)) { _ in
                await self.handleAppRefreshTask()
            }
        }
    }
}

//MARK: - Make View
extension WeatherIsMyMoodApp {
    private func makeMainView(locationManager: LocationManager,
                              storageManager: FirestoreManager) -> some View {
        return MainView(locationManager: locationManager, storageManager: storageManager)
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

//MARK: - Background Task
extension WeatherIsMyMoodApp {
    
    private func scheduleBgAppRefreshTask() {
        
        let today = Calendar.current.startOfDay(for: .now)
        let component = DateComponents(minute: 30)
        let term = Calendar.current.date(byAdding: component, to: today)
        
        let request = BGAppRefreshTaskRequest(identifier: BGTaskConstants.testId)
        request.earliestBeginDate = term
        
        do {
            try BGTaskScheduler.shared.submit(request)
            #if DEBUG
            print("Successfully submitted refresh request.")
            #endif
        }
        catch {
            #if DEBUG
            print("Error submitting request - \(error)")
            #endif

        }
    }
    
    //MARK: - Handle BG Task
    private func handleAppRefreshTask() async {
        self.scheduleBgAppRefreshTask()
        guard let location = self.locationManager.currentLocation else { return }
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            NotificationCenter.default.post(name: Notification.Name(NotificationKeys.backgroundUpdate), object: weather)
            UserDefaults.standard.set(weather.currentWeather.condition.weatherIcon, forKey: "app_refresh_weather")
        }
        catch {
            print("Error fetching weather -- \(error)")
        }
        
        let savedCount = UserDefaults.standard.integer(forKey: "app_refresh_demo")
        UserDefaults.standard.set(savedCount + 1, forKey: "app_refresh_demo")
       
    }

    private func checkSavedBackgroundTasks() {
        let savedCount = UserDefaults.standard.integer(forKey: "app_refresh_demo")
        let savedWeather = UserDefaults.standard.string(forKey: "app_refresh_weather")
        print("Saved Count in BG: \(savedCount)")
        print("Saved weather in BG: \(String(describing: savedWeather))")
    }
}

