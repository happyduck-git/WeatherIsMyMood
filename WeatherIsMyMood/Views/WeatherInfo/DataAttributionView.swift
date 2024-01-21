//
//  DataAttributionView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct DataAttributionView: View {
    var weatherAttribution: WeatherAttribution?
    
    var body: some View {
        if let attrib = weatherAttribution {
            VStack {
                let url = ColorScheme(.dark) != nil ? attrib.combinedMarkLightURL : attrib.combinedMarkDarkURL
                
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 30)
                } placeholder: {
                    ProgressView()
                }

                
                Link(destination: attrib.legalPageURL, label: {
                    Text("Weather Data Attribution")
                        .font(.caption)
                })
            }
        }
    }
}

#Preview {
    WeatherView(locationManager: LocationManager())
}
