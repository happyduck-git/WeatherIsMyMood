//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by HappyDuck on 12/12/23.
//

import WidgetKit
import SwiftUI
import UIKit.UIImage

struct WeatherWidget: Widget {
    
    @State var topInset: CGFloat = 20
    @State var sideInset: CGFloat = 20
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherAttributes.self) { ctx in
            
            VStack(alignment: .leading) {
                HStack {
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    Text(WidgetConstants.appName)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: topInset, leading: sideInset, bottom: 0, trailing: sideInset))
                
                HStack(alignment: .center) {
                    Text(WidgetConstants.currentTemp)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding()
                    Text(ctx.state.temperature)
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .padding()
                }
                .padding(EdgeInsets(top: 0, leading: sideInset, bottom: 0, trailing: sideInset))
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(ColorConstants.widgetMain).gradient)
                    HStack {
                        Spacer()
                        if let image = UIImage(data: ctx.state.icon) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 70, height: 70)
                                .aspectRatio(contentMode: .fit)
                                .padding()
                                .opacity(0.7)
                        }
                    }
                    
                }
                
            }
            
        } dynamicIsland: { ctx in
            
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center) {
                        if let image = UIImage(data: ctx.state.icon) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .aspectRatio(contentMode: .fit)
                        }
                        Text(WidgetConstants.appName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxHeight: .infinity)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(ctx.state.temperature)
                        .font(.headline)
                        .padding()
                }
            } compactLeading: {
                
                if let image = UIImage(data: ctx.state.icon) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } compactTrailing: {
                Text(ctx.state.temperature)
                
            } minimal: {
                if let image = UIImage(data: ctx.state.icon) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            
        }
        
    }
}

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}
