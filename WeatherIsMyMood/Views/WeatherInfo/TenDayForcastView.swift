//
//  TenDayForcastView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI
import WeatherKit

struct TenDayForcastView: View {
    let dayWeatherList: [DayWeather]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                WeatherTitleView(title: WeatherConstants.tenDayForcast)
                    .shadow(radius: 10)
                ForEach(dayWeatherList, id: \.date) {
                    item in
                    VStack {
                        HStack {
                            Text(item.date.formateAsAbbreviatedDay())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "\(item.symbolName)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.lowTemperature.formatted())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.highTemperature.formatted())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding()
                        Divider()
                            .padding(EdgeInsets(top: -10, leading: 10, bottom: -100, trailing: 10))
                    }
                        
                }
            }
            
            .background(
                LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottom)
                    .opacity(0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .shadow(radius: 10)
            )
            
        }
        
    }
}

#Preview {
    WeatherView()
}
