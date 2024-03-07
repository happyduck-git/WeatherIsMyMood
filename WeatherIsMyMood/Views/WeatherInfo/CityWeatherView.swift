//
//  CityWeatherView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import SwiftUI
import WeatherKit
import Alamofire

struct CityWeatherView: View {
    
    //MARK: - Properties
    @Binding var weather: Weather?
    @Binding var cityName: String
    @Binding var aqList: [AQList]
    
    /* View Degree */
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = false
    
    let durationAndDelay : CGFloat = 0.18
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                flipView()
            }, label: {
                VStack(alignment: .trailing) {
                    Text(isFlipped ? WeatherConstants.weather : WeatherConstants.showAirQuality)
                    Image(systemName: isFlipped ? "sun.max.circle" : "aqi.medium")
                        .resizable()
                        .foregroundStyle(isFlipped ? .orange : .secondary)
                        .frame(width: 20, height: 20)
                }
            })
            .modify {
                if #available(iOS 17.0, *) {
                    $0.symbolEffect(.pulse)
                } else {
                    $0
                }
            }
            
            CityWeatherFrontView(weather: self.$weather,
                                 cityName: self.$cityName,
                                 degree: $backDegree)
        
            CityWeatherBackView(degree: $frontDegree,
                                aqList: $aqList)
          
        }
    }
}

extension CityWeatherView {
    private func flipView() {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                backDegree = 0
            }
        }
    }
}
