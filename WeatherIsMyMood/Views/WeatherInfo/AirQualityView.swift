//
//  AirQualityView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/19/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct AirQualityView: View {
    @Binding var aqList: [AQList]
    @State private var today: AQICategory.Resources?
    @State private var otherDays: [AQICategory.Resources] = []
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                SectionTitleView(section: .airQuality)
                    .shadow(radius: 10)
                    .frame(width: 200)
                Spacer()
                Button(action: {
                    self.collapsed.toggle()
                }, label: {
                    HStack {
                        Text(self.collapsed ? WeatherConstants.showMore : WeatherConstants.showLess)
                            .foregroundStyle(.indigo)
                        Image(systemName: self.collapsed ? "chevron.down.circle" : "chevron.up.circle")
                            .foregroundStyle(.indigo)
                    }
                })
                .padding(.horizontal)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            self.makeWeatherRow(self.today)
                .background(
                    self.makeGradientBackgound()
                )
            VStack(alignment: .leading) {
 
                ForEach(self.otherDays, id: \.description) { item in
                    self.makeWeatherRow(item)
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .background(
                self.makeGradientBackgound()
            )
            .animation(.bouncy, value: collapsed)
            .transition(.slide)
        }
        .modify {
            if #available(iOS 17.0, *) {
                $0.onChange(of: self.aqList) {
                    self.divideAndSetValues()
                }
            } else {
                $0.onChange(of: self.aqList) { _ in
                    self.divideAndSetValues()
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeWeatherRow(_ aqi: AQICategory.Resources?) -> some View {
        if let aqi {
            VStack {
                HStack {
                    aqi.icon
                        .resizable()
                        .frame(width: 30, height: 30)
                    Spacer()
                    Text(aqi.description)
                }
                .padding()
                
                Divider()
                    .padding(EdgeInsets(top: -10, leading: 10, bottom: -100, trailing: 10))
            }
        } else {
            VStack(content: {
                Text(WeatherConstants.noDataFound)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            })
        }
        
    }
    
}

extension AirQualityView {
    
    private func divideAndSetValues() {
        var resources = self.processAQList(self.aqList)
        self.today = resources.removeFirst()
        self.otherDays = resources
    }
    
    private func processAQList(_ aqListArr: [AQList]) -> [AQICategory.Resources] {
        return aqListArr[0...9].compactMap { self.convertToCategoryResources($0) }
    }
    
    private func convertToCategoryResources(_ aqList: AQList?) -> AQICategory.Resources? {
        return AQICategory.categoryForIndex(aqList?.main.aqi ?? 0).categoryResources
    }
}

extension AirQualityView {
    private func makeGradientBackgound() -> some View {
        LinearGradient(colors: [.skyblue, .pink], startPoint: .topLeading, endPoint: .bottom)
            .opacity(0.3)
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .shadow(radius: 10)
    }
}
