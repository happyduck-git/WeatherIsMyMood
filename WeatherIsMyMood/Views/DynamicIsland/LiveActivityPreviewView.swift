//
//  DynamicIslandPreviewView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit
import CoreLocation
import UIKit
import Combine

struct LiveActivityPreviewView: View {
    
    @Binding var weather: Weather?
    @Binding var selectedColor: Color
    @Binding var selectedTextColor: Color
    @Binding var selectedIcon: Data?
    @Binding var newBgColor: Color
    @Binding var newTextColor: Color
    @Binding var newIcon: Data?
    @Binding var updateNeeded: Bool
    @Binding var isSystemColor: Bool
    
    @State private var temperature: String = "0"
    @State private var showColorPalettes = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
        if let _ = weather {
            
            VStack {
                self.makeDynamicIslandPreview(icon: newIcon, temperature: temperature)
                self.makeLockScreenPreview(icon: newIcon, temperature: temperature)
            }
            .onAppear {
                self.temperature = self.convertFormat(temperature: self.weather?.currentWeather.temperature)
            }
            .onChange(of: self.weather, perform: { _ in
                self.temperature = self.convertFormat(temperature: self.weather?.currentWeather.temperature)
                print("Weather on DPV has changed -- \(String(describing: self.selectedIcon))")
            })
            .onChange(of: self.newBgColor) { _ in
                self.updateNeeded = true
            }
            .onChange(of: self.newTextColor) { _ in
                self.updateNeeded = true
            }
            .onChange(of: self.newIcon) { _ in
                self.updateNeeded = true
            }
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
                    self.defaultWeatherImage()
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
                        .foregroundStyle(isSystemColor ? .primary : self.newTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.5)
                    HStack {
                        Text(WidgetConstants.currentTemp)
                            .font(.system(size: 16))
                            .foregroundStyle(isSystemColor ? .primary : self.newTextColor)
                            .opacity(0.5)
                        
                        Text(temperature)
                            .font(.system(size: 16))
                            .foregroundStyle(isSystemColor ? .primary : self.newTextColor)
                    }
                }
                Spacer()
                if let icon, let image = UIImage(data: icon) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                } else {
                    self.defaultWeatherImage()
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(isSystemColor ? .widgetBG : self.newBgColor)
            }
            
            Button {
                self.showColorPalettes.toggle()
            } label: {
                Image(systemName: "paintpalette.fill")
                    .symbolRenderingMode(.multicolor)
                
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
            .sheet(isPresented: self.$showColorPalettes) {
                self.makeBottomSheetView()
                    .presentationDetents([.height(self.isSystemColor ? 180 : 200)]) //TODO: Add smooth transition animation.
                    .animation(.bouncy, value: true)
            }
        }
        .frame(width: 310, height: 80)
    }
    
    @ViewBuilder
    private func makeBottomSheetView() -> some View {
        VStack(alignment: .leading) {
            Text(DecoConstants.selectColor)
                .font(.title2)
                .bold()
                .padding()
            HStack {
                Toggle(isOn: self.$isSystemColor) {
                    Text(DecoConstants.systemColor)
                        .bold()
                }
                .modify {
                    if #available(iOS 17.0, *) {
                        $0.onChange(of: self.isSystemColor) {
                            if self.isSystemColor { self.updateNeeded = true }
                        }
                    } else {
                        $0.onChange(of: self.isSystemColor) { _ in
                            if self.isSystemColor { self.updateNeeded = true }
                        }
                    }
                }
            }
            .padding(.horizontal)
            makePaletteView(title: DecoConstants.text, color: self.$newTextColor, systemSetting: self.isSystemColor)
            makePaletteView(title: DecoConstants.background, color: self.$newBgColor, systemSetting: self.isSystemColor)
            
        }
        .padding()
    }
    
    @ViewBuilder
    private func makePaletteView(title: String, color: Binding<Color>, systemSetting: Bool) -> some View {
        ColorPicker(selection: color,
                    supportsOpacity: false) {
            Text(title)
                .bold()
        }.padding(.horizontal)
            .opacity(self.isSystemColor ? 0.0 : 1.0)
    }
    
    private func defaultWeatherImage() -> some View {
        Image(systemName: "circle.dashed")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.gray)
            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
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
}

#Preview {
    DecorationView()
}
