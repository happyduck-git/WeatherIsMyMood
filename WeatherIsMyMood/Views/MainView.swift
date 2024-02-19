//
//  MainView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import CoreLocation

struct MainView: View {
    
    @ObservedObject private var locationManager: LocationManager
    private let storageManager: FirestoreManager
    
    //MARK: - Init
    init(locationManager: LocationManager,
         storageManager: FirestoreManager) {
        self.locationManager = locationManager
        self.storageManager = storageManager
    }
    
    //MARK: - Body
    var body: some View {
        TabView {
            WeatherView(locationManager: self.locationManager,
                        storageManager: self.storageManager)
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }
            DecorationView(locationManager: self.locationManager,
                           storageManager: self.storageManager)
                .tabItem {
                    Label("Deco", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    MainView(locationManager: LocationManager(locationFetcher: CLLocationManager()),
             storageManager: FirestoreManager())
}
