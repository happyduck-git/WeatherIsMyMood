//
//  EnableToggleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI
import ActivityKit
import WeatherKit

extension Activity: Equatable {
    public static func == (lhs: Activity<Attributes>, rhs: Activity<Attributes>) -> Bool {
        return lhs.id == rhs.id
    }
}

struct EnableToggleView: View {
    
    private let notiPulisher =  NotificationCenter.default
        .publisher(for: Notification.Name(NotificationKeys.backgroundUpdate), object: nil)
    
    @State private var activity: Activity<WeatherAttributes>? = nil
    @State private var deviceToken: String = ""
    @State private var pushToken: String = ""
    @Binding var isOn: Bool
    @Binding var weather: Weather?
    @Binding var selectedIcon: Data?
    
    var body: some View {
        VStack {
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
            HStack {
                Text("Device Token: \(self.deviceToken)")
                Button(action: {
                    self.pasteToClipboard(self.deviceToken)
                }, label: {
                    Text("키 복사")
                })
            }
            Divider()
            
            HStack {
                Text("Push Token: \(self.pushToken)")
                Button(action: {
                    self.pasteToClipboard(self.pushToken)
                }, label: {
                    Text("키 복사")
                })
            }
            Divider()
            
            HStack {
                Text("Activity Token: \(self.activity?.id ?? "없음")")
                Button(action: {
                    self.pasteToClipboard("\(self.activity?.id ?? "없음")")
                }, label: {
                    Text("복사")
                })
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(UserDefaultsKeys.deviceToken)), perform: {
            guard let token = $0.object as? String else {
                return
            }
            self.deviceToken = token
        })
        .onChange(of: self.isOn, perform: { newValue in
            self.enableLiveActivity(self.isOn)
        })
        .onChange(of: self.selectedIcon, perform: { _ in
            self.updateLiveActivity(self.isOn)
        })
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

extension EnableToggleView {
    private func updateLiveActivity(_ isOn: Bool) {
        if isOn {
            Task {
                
                guard let weather, let selectedIcon else {
                    return
                }

                guard let activity else {
                    self.enableLiveActivity(isOn)
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
                                                                        content: content,
                                                                        pushType: .token)
                
                guard let activity = self.activity else { return }
                Task {
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
                        print("New push token: \(pushTokenString)")
                        self.pushToken = pushTokenString
                    }
                }
                
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

//MARK: - APNS DEMO PURPOSE LOGICS
extension EnableToggleView {
    private func pasteToClipboard(_ str: String) {
        UIPasteboard.general.string = str
    }
}
