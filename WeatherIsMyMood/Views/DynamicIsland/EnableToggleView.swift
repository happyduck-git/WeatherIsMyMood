//
//  EnableToggleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI
import ActivityKit
import WeatherKit

struct EnableToggleView: View {
    
    @State private var activity: Activity<WeatherAttributes>? = nil
    @Binding var isOn: Bool
    @Binding var weather: Weather?
    @Binding var selectedIcon: Data?
    
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Text("Enable Dynamic island")
            }
            .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white)
                .padding()
        }
        .onChange(of: self.isOn) {
            self.enableLiveActivity(self.isOn)
        }
    }
}

extension EnableToggleView {
    private func enableLiveActivity(_ isOn: Bool) {
        if isOn {
            if let weather, let selectedIcon {
                let attrib = WeatherAttributes()
                let content = ActivityContent.init(state: WeatherAttributes.ContentState(
                    icon: selectedIcon,
                    temperature: "\(weather.currentWeather.temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))"),
                                                   staleDate: nil)
                
                
                do {
                    self.activity = try Activity<WeatherAttributes>.request(attributes: attrib,
                                                                            content: content)
                }
                catch {
                    print("Error unwrapping weather, selectedIcon optional value. -- \(error)")
                }
                
            } else {
                
            }
            
        } else {
            Task {
                let content = ActivityContent.init(state: WeatherAttributes.ContentState(icon: Data(), temperature: ""),
                                                   staleDate: nil)
                await self.activity?.end(content,
                                         dismissalPolicy:.immediate)
            }
        }
    }
}

