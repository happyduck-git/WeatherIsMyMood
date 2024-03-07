//
//  MainView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import CoreLocation

struct MainView: View {
 
    //MARK: - Body
    var body: some View {
        TabView {
            WeatherView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }
            DecorationView()
                .tabItem {
                    Label("Deco", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    MainView()
}
