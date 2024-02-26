//
//  DynamicIslandPreviewView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct LiveActivityPreviewView: View {
    
    @Binding var weather: Weather?
    @Binding var selectedIcon: Data?
    @State var selectedColor: Color = Color.widgetBG
    @State var selectedTextColor: Color = .primary
    @State private var temperature: String = "0"
    @State private var showColorPalettes = false
    
    var body: some View {
        if let weather {
            
            VStack {
                self.makeDynamicIslandPreview(icon: selectedIcon, temperature: temperature)
                self.makeLockScreenPreview(icon: selectedIcon, temperature: temperature)
            }
            .onAppear {
                self.temperature = self.convertFormat(temperature: self.weather?.currentWeather.temperature)
            }
            .onChange(of: self.weather, perform: { _ in
                self.temperature = self.convertFormat(temperature: self.weather?.currentWeather.temperature)
                print("Weather on DPV has changed -- \(String(describing: self.selectedIcon))")
            })
        }
    }
}

extension LiveActivityPreviewView {
    
    @ViewBuilder
    private func makeDynamicIslandPreview(icon: Data?, temperature: String) -> some View {
        ZStack(alignment: .leading) {
            HStack {
                if let icon, let image = UIImage(data: icon) {
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
                
                Text(temperature)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 100, style: .circular)
                .fill(.black)
                .frame(height: 40)
        }
        .padding(EdgeInsets(top: 5, leading: 120, bottom: 5, trailing: 120))
    }
    
    @ViewBuilder
    private func makeLockScreenPreview(icon: Data?, temperature: String) -> some View {
        HStack {
            HStack(alignment: .center) {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(WidgetConstants.appName)
                        .font(.system(size: 12))
                        .foregroundStyle(self.selectedTextColor.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(WidgetConstants.currentTemp)
                            .font(.system(size: 16))
                            .foregroundStyle(self.selectedTextColor.opacity(0.5))
                        
                        Text(temperature)
                            .font(.system(size: 16))
                            .foregroundStyle(self.selectedTextColor)
                    }
                }
                Spacer()
                if let icon, let image = UIImage(data: icon) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(.clearCloudy)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(self.selectedColor)
                    
            }
            
            Button {
                // Back to original color
//                self.selectedColor = .widgetBG
                self.showColorPalettes.toggle()
            } label: {
                Image(systemName: "paintpalette.fill")
                    .symbolRenderingMode(.multicolor)
                
            }
            .sheet(isPresented: self.$showColorPalettes) {
                
                self.makeBottomSheetView()
                    .presentationDetents([.height(200)])
            }
        }
        .frame(width: 310, height: 80)
    }
    
    @ViewBuilder
    private func makeBottomSheetView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Select Color")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    self.resetColor()
                } label: {
                    VStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Reset")
                    }
                }
            }
            .padding()
            
            makePaletteView(title: "Text", color: self.$selectedTextColor)
            makePaletteView(title: "Background", color: self.$selectedColor)
        }
        
    }
    
    @ViewBuilder
    private func makePaletteView(title: String, color: Binding<Color>) -> some View {
        HStack {
            Text(title)
            ColorPicker(selection: color,
                        supportsOpacity: false) {
                Text("ColorPicker")
            }.labelsHidden()
        }
        .padding(.horizontal)
    }
}

extension LiveActivityPreviewView {
    private func convertFormat(temperature: Measurement<UnitTemperature>?) -> String {
        if let temperature {
            return temperature.formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0))))
        } else {
            return "0"
        }
    }
    
    private func resetColor() {
        self.selectedColor = .widgetBG
        self.selectedTextColor = .primary
    }
}

//struct DynamicIslandPreviewView_Previews: PreviewProvider {
//    @State static var weather: Weather? = nil
//    @State static var selectedIcon: Data? = nil // Replace 'YourIconType' with the actual type
//    
//    static var previews: some View {
//        DynamicIslandPreviewView(weather: $weather, selectedIcon: $selectedIcon)
//    }
//}


#Preview {
//    DynamicIslandPreviewView_Previews() as! any View
    DecorationView()
}

import SwiftUI
import UIKit

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
