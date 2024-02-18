//
//  CityWeatherBackView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import SwiftUI

struct CityWeatherBackView: View {
    
    @Binding var degree : Double
    @Binding var aqList: [AQList]
    @State private var todayAqResources: AQICategory.Resources?
    @State private var todayAqComponentsResources: [Pollutant: AQICategory.Resources] = [:]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.skyblue)
                .opacity(0.3)
            VStack(alignment: .center) {
                Text(WeatherConstants.airQuality)
                    .font(.title)
                    .fontWeight(.semibold)
                
                self.makeAqVieq()
                self.makePollutantsView()
            }
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
        .modify{
            if #available(iOS 17.0, *) {
                $0.onChange(of: aqList) {
                    self.todayAqResources = getCategoryResources()
                    self.todayAqComponentsResources = getPollutantsResources()
                }
            } else {
                $0.onChange(of: aqList) { _ in
                    self.todayAqResources = getCategoryResources()
                    self.todayAqComponentsResources = getPollutantsResources()
                }
            }
        }
    }
    
}

//MARK: - Data Process
extension CityWeatherBackView {
    
    private func getCategoryResources() -> AQICategory.Resources? {
        return AQICategory.categoryForIndex(aqList.first?.main.aqi ?? 0).categoryResources
    }
    
    private func getPollutantsResources() -> [Pollutant: AQICategory.Resources] {
        var components: [Pollutant: AQICategory.Resources] = [:]
        if let aqList = aqList.first {
            components[Pollutant.co(aqList.components.co)] = Pollutant.co(aqList.components.co).category().categoryResources
            components[Pollutant.no2(aqList.components.no2)] = Pollutant.no2(aqList.components.no2).category().categoryResources
            components[Pollutant.o3(aqList.components.o3)] = Pollutant.o3(aqList.components.o3).category().categoryResources
            components[Pollutant.so2(aqList.components.so2)] = Pollutant.so2(aqList.components.so2).category().categoryResources
            components[Pollutant.pm2_5(aqList.components.pm2_5)] = Pollutant.pm2_5(aqList.components.pm2_5).category().categoryResources
            components[Pollutant.pm10(aqList.components.pm10)] = Pollutant.pm10(aqList.components.pm10).category().categoryResources
        }
        return components
    }
    
}

//MARK: - Make Views
extension CityWeatherBackView {
    @ViewBuilder
    private func makeAqVieq() -> some View {
        if let aqi = self.todayAqResources {
            HStack {
                aqi.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .scaledToFit()
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 10))
                    
                Text(aqi.description)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 10))
                    .fontWeight(.semibold)
                    .font(.body)
            }
        } else {
            Text("Cannot bring air quality..")
        }
    }
    
    private func makePollutantsView() -> some View {
        let sortedKeys = self.todayAqComponentsResources.keys.sorted()
        
        return VStack(alignment: .leading) {
            ForEach(sortedKeys, id: \.self) { key in
                if let resource = self.todayAqComponentsResources[key] {
                    HStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(resource.color)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 10))
                        Text(key.description)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 10))
                            .font(.caption)
                        Text(resource.description)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                            .fontWeight(.semibold)
                            .font(.caption)
                    }
                    
                }
            }
        }
    }
}
