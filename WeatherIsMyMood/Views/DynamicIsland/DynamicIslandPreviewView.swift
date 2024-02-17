//
//  DynamicIslandPreviewView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct DynamicIslandPreviewView: View {
    
    @Binding var weather: Weather?
    @Binding var selectedIcon: Data?
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            HStack {
                if let weather {
                    if let icon = selectedIcon,
                       let image = UIImage(data: icon) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
                    } else {
                        Image(.clearCloudy)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
                    }
                    
                    Spacer()
                    
                    Text("\(weather.currentWeather.temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))")
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
                }
                
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 100, style: .circular)
                .fill(.black)
                .frame(height: 40)
        }
        .onChange(of: self.weather, perform: { _ in
            print("Weather on DPV has changed -- \(String(describing: self.selectedIcon))")
        })
    }
}

struct DynamicIslandPreviewView_Previews: PreviewProvider {
    @State static var weather: Weather? = nil
    @State static var selectedIcon: Data? = nil // Replace 'YourIconType' with the actual type
    
    static var previews: some View {
        DynamicIslandPreviewView(weather: $weather, selectedIcon: $selectedIcon)
    }
}


#Preview {
    DynamicIslandPreviewView_Previews() as! any View
}
