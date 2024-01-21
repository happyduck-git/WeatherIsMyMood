//
//  MainView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI

struct MainView: View {
    let locationManager: LocationManager = LocationManager()
    
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
    MainView()
}
