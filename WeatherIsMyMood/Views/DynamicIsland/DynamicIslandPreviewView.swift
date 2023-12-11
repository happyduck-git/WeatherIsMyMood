//
//  DynamicIslandPreviewView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit

struct DynamicIslandPreviewView: View {
    
    @Binding var weather: Weather?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.orange)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
               
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .padding(EdgeInsets(top: 30, leading: 120, bottom: 30, trailing: 120))
                
                HStack {
                    if let weather {
//                        Image(weather.currentWeather.condition.weatherIcon) // Dev & Prod
                        Image(.clearCloudy) // Demo
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(EdgeInsets(top: 0, leading: 130, bottom: 0, trailing: 0))
                        
                    Spacer()
                    
                    
                        Text("\(weather.currentWeather.temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))")
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 130))
                    }
                   
                }

            }
        }
        .frame(height: 100)
    }
}

#Preview {
    DecorationView()
}
