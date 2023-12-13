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
                Text(DecoConstants.enable)
            }
            .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.tertiary)
                .padding()
        }
        .onChange(of: self.isOn, perform: { newValue in
            self.enableLiveActivity(self.isOn)
        })
        .onChange(of: self.selectedIcon, perform: { _ in
            self.updateLiveActivity(self.isOn)
        })
    }
}

extension EnableToggleView {
    private func updateLiveActivity(_ isOn: Bool) {
        if isOn {
            Task {
                guard let activity, let weather, let selectedIcon else {
                    return
                }
                    
                let content = ActivityContent.init(state: WeatherAttributes.ContentState(
                    icon: selectedIcon,
                    temperature: self.formatTemperature(weather.currentWeather.temperature)),
                                                   staleDate: nil)
                await activity.update(content)
            }
        }
    }
    
    private func enableLiveActivity(_ isOn: Bool) {

        if isOn {
            guard let weather, let selectedIcon else {
                return
            }
            
            let attrib = WeatherAttributes()
            
            let content = ActivityContent.init(state: WeatherAttributes.ContentState(
                icon: selectedIcon,
                temperature: self.formatTemperature(weather.currentWeather.temperature)),
                                               staleDate: nil
            )
            
            do {
                self.activity = try Activity<WeatherAttributes>.request(attributes: attrib,
                                                                        content: content)
            }
            catch {
                print("Error unwrapping weather, selectedIcon optional value. -- \(error)")
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

extension EnableToggleView {
    private func formatTemperature(_ temperature: Measurement<UnitTemperature>) -> String {
        return "\(temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))"
    }
}
