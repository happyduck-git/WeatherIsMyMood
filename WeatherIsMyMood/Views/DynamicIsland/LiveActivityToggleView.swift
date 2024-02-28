//
//  LiveActivityToggleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI
import ActivityKit
import WeatherKit
import UIKit.UIColor

enum LiveActivityError: Error {
    case iconNotSelected
}

struct LiveActivityToggleView: View {
    
    private let notiPulisher =  NotificationCenter.default
        .publisher(for: Notification.Name(NotificationKeys.backgroundUpdate), object: nil)
    
    @State private var pushToken: String = String()
    @State private var activity: Activity<WeatherAttributes>? = nil
    @State private var activityError: LiveActivityError? = nil
    @State private var isHidden: Bool = true
    @Binding var isOn: Bool
    @Binding var weather: Weather?
    @Binding var selectedIcon: Data?
    @Binding var selectedColor: Color
    @Binding var selectedTextColor: Color
    @Binding var isConfirmed: Bool
    
    private let defaultColor: [CGFloat] = [0, 0, 0, 1.0]
    
    var body: some View {
        VStack {
            Text(pushToken)
            Button {
                UIPasteboard.general.string = pushToken
            } label: {
                Text("복사하기")
            }
            
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
        }
//        .onAppear(perform: {
//            print("LIVETOGGLEVIEW: \(self.selectedColor)")
//        })
        .modify {
            if #available(iOS 17.0, *) {
                $0.onChange(of: self.isOn) {
                    //TODO: Send server a new token.
                    self.enableLiveActivity(self.isOn)
                }
                .onChange(of: self.isConfirmed) {
                    if $0 {
                        // If users confirm change, enable LA again
                       //TODO: and send server a new token.
                        self.enableLiveActivity(self.isOn)
                    } else {
                        // If users did not confirm change, no action needed.
                    }
                }
            } else {
                $0.onChange(of: self.isOn, perform: { newValue in
                    self.enableLiveActivity(self.isOn)
                })
            }
        }
//        .onChange(of: self.selectedIcon, perform: { _ in
//            self.updateLiveActivity(self.isOn)
//        })
        .onChange(of: self.weather) { _ in
            #if DEBUG
            print("Weather is updated.")
            #endif
            self.updateLiveActivity(self.isOn)
        }
        .onReceive(notiPulisher) { output in
            #if DEBUG
            print("✅Receive noti from app \(output)")
            #endif
            self.updateLiveActivity(self.isOn)
        }
    }
}

extension LiveActivityToggleView {
    private func updateLiveActivity(_ isOn: Bool) {
        if isOn {
            Task {
                
                guard let weather else {
                    return
                }

                guard let activity else {
                    self.enableLiveActivity(isOn)
                    return
                }
                
                let content = ActivityContent.init(state: WeatherAttributes.ContentState(
                    temperature: self.formatTemperature(weather.currentWeather.temperature)),
                                                   staleDate: nil)
                await activity.update(content)
            }
        }
    }
    
    private func enableLiveActivity(_ isOn: Bool) {
        
        if isOn {
            if self.activity?.activityState == .active || self.activity?.activityState == .stale {
                self.endCurrentActivity()
            }
            guard let weather, let selectedIcon else { return }

            let attrib = WeatherAttributes(bgColors: selectedColor,
                                           textColors: selectedTextColor,
                                           icon: selectedIcon)
            
            let content = ActivityContent.init(
                state: WeatherAttributes.ContentState(
                    temperature: self.formatTemperature(weather.currentWeather.temperature)
                ),
                staleDate: nil
            )
            
            do {
                self.activity = try Activity<WeatherAttributes>.request(attributes: attrib,
                                                                        content: content,
                                                                        pushType: .token)
                
                guard let activity = self.activity else {
                    print("Actionvty found nil")
                    return
                }
                
                Task {
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
                        #if DEBUG
                        print("New push token: \(pushTokenString)")
                        #endif
                        self.pushToken = pushTokenString
                    }
                    print("PUsh token for loop ended.")
                }
                self.isConfirmed = false
            }
            catch {
                print("Error requesting a live activity. -- \(error)")
            }

        } else {
            self.endCurrentActivity()
            
        }
    }
    
    private func endCurrentActivity() {
        Task {
            let content = ActivityContent.init(
                state: WeatherAttributes.ContentState(
                    temperature: ""
                ),
                staleDate: nil
            )
            await self.activity?.end(content,
                                     dismissalPolicy:.immediate)
            print(self.activity?.activityState)
        }
    }
}


extension LiveActivityToggleView {
    private func formatTemperature(_ temperature: Measurement<UnitTemperature>) -> String {
        return "\(temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))"
    }
}
