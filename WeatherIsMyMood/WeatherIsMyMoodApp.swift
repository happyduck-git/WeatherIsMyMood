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
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will be terminated.")
    }
}

@main
struct WeatherIsMyMoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var locationManager: LocationManager = LocationManager(locationFetcher: CLLocationManager())
    
    @ObservedObject private var bgTimeManger = BackgroundTimer()
    @State private var tasks: [UIBackgroundTaskIdentifier] = []
    
    var body: some Scene {

        if #available(iOS 17.0, *) {
            return WindowGroup {
                self.makeMainView(with: self.locationManager)
                    .onAppear {
                        bgTimeManger.delegate = self
                    }
            }
            .onChange(of: phase, initial: true) { _, newPhase in
                switch newPhase {
                case .active:
                    self.cancelBackgroundTask(tasks: self.tasks)
                    
                case .background:
                    self.tasks.append(setUpBackgroundUpdate(delay: 60 * 30, repeating: true))
                    
                    let savedCount = UserDefaults.standard.integer(forKey: "app_refresh_demo")
                    print("Saved Count in BG: \(savedCount)")
                    let savedWeather = UserDefaults.standard.object(forKey: "app_refresh_weather")
                    print("Saved weather in BG: \(String(describing: savedWeather))")
                    
                    scheduleBgAppRefreshTask()
                default: break
                }
            }
            .backgroundTask(.appRefresh(BGTaskConstants.testId)) { _ in
                await self.handleAppRefreshTask()
                print("BG_refresh")
            }
          
        } else {
            return WindowGroup {
                self.makeMainView(with: self.locationManager)
            }
            .onChange(of: phase) { newPhase in
                switch newPhase {
                case .background:
                    let savedCount = UserDefaults.standard.integer(forKey: "app_refresh_demo")
                    print("Saved Count in BG: \(savedCount)")
                    
                    let savedWeather = UserDefaults.standard.string(forKey: "app_refresh_weather")
                    print("Saved weather in BG: \(String(describing: savedWeather))")
                    
                    scheduleBgAppRefreshTask()
                default: break
                }
            }
            .backgroundTask(.appRefresh(BGTaskConstants.testId)) { _ in
                await self.handleAppRefreshTask()
                print("BG_refresh")
            }
          
        }
    }
    
    private func makeMainView(with locationManager: LocationManager) -> some View {
        return MainView(locationManager: locationManager)
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
    
    //MARK: - Schedule BG Task
    
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
    
    private func setUpBackgroundUpdate(delay interval: TimeInterval, repeating: Bool) -> UIBackgroundTaskIdentifier {
        let taskID = self.bgTimeManger.executeAfterDelay(delay: interval, repeating: repeating) {
            //TODO: 
            print("Repeating on background...")
        }
        
        return taskID
    }
    
    private func cancelBackgroundTask(tasks: [UIBackgroundTaskIdentifier]) {
        guard !tasks.isEmpty else { return }
        self.bgTimeManger.cancelExecution(tasks: tasks)
    }
}

extension WeatherIsMyMoodApp: BackgroundTimerDelegate {
    func backgroundTimerTaskExecuted(task: UIBackgroundTaskIdentifier, willRepeat: Bool) {
        guard !willRepeat else {
            return
        }
        
        //TODO: - Handle task execution
    }
    
    func backgroundTimerTaskCanceled(task: UIBackgroundTaskIdentifier) {
        //TODO: - Handle task cancelation
        self.tasks.removeAll()
    }

    private func scheduleBgTask() {
        let request = BGProcessingTaskRequest(identifier: BGTaskConstants.weatherUpdateId)
        request.earliestBeginDate = .now.addingTimeInterval(3600*3)
        request.requiresExternalPower = true
        request.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
            #if DEBUG
            print("Successfully submitted processing request.")
            #endif
        }
        catch {
            #if DEBUG
            print("Error submitting request - \(error)")
            #endif
        }
    }
}

