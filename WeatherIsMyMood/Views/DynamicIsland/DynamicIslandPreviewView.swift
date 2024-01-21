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
    @Binding var selectedIcon: Data?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.clear)
                .background {
                    LinearGradient(colors: [.black.opacity(0.3), .clear, .black.opacity(0.1)],
                                   startPoint: .topLeading,
                                   endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
               
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .fill(.black)
                    .padding(EdgeInsets(top: 30, leading: 120, bottom: 30, trailing: 120))
                
                HStack {
                    if let weather {
                       if let icon = selectedIcon,
                          let image = UIImage(data: icon) {
                           Image(uiImage: image)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 20, height: 20)
                               .padding(EdgeInsets(top: 0, leading: 130, bottom: 0, trailing: 0))
                       }
                        else {
                            Image(.clearCloudy)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(EdgeInsets(top: 0, leading: 130, bottom: 0, trailing: 0))
                        }
                        
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
    DecorationView(locationManager: LocationManager())
}
