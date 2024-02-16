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
    
    //MARK: - Init
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    //MARK: - Body
    var body: some View {
        TabView {
            WeatherView(locationManager: self.locationManager)
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }
            DecorationView(locationManager: self.locationManager)
                .tabItem {
                    Label("Deco", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    MainView(locationManager: LocationManager(locationFetcher: CLLocationManager()))
}
