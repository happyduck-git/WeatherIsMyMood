//
//  WeatherLiveActivityWidget.swift
//  WeatherWidget
//
//  Created by HappyDuck on 12/12/23.
//

import WidgetKit
import SwiftUI
import UIKit.UIImage
import UIKit

struct WeatherLiveActivityWidget: Widget {
    
    private let sideInset: CGFloat = 20
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherAttributes.self) { ctx in
            
            HStack(alignment: .center) {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(WidgetConstants.appName)
                        .font(.system(size: 12))
                        .foregroundStyle(
//                            Color(red: ctx.attributes.textColors.red,
//                                  green: ctx.attributes.textColors.green,
//                                  blue: ctx.attributes.textColors.blue)
                            ctx.attributes
                                .textColors
                                .opacity(0.5)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(WidgetConstants.currentTemp)
                            .font(.system(size: 16))
                            .foregroundStyle(
//                                Color(red: ctx.attributes.textColors.red,
//                                      green: ctx.attributes.textColors.green,
//                                      blue: ctx.attributes.textColors.blue)
                                ctx.attributes
                                    .textColors
                                    .opacity(0.5)
                            )
                        
                        Text(ctx.state.temperature)
                            .font(.system(size: 16))
                            .foregroundStyle(
                                ctx.attributes
                                    .textColors

//                                Color(red: ctx.attributes.textColors.red,
//                                      green: ctx.attributes.textColors.green,
//                                      blue: ctx.attributes.textColors.blue)
                            )
                    }
                }
                Spacer()
                if let image = UIImage(data: ctx.attributes.icon) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(EdgeInsets(top: 0, leading: sideInset, bottom: 0, trailing: sideInset))
            .background {
                ctx.attributes
                    .bgColors
//                Color(red: ctx.attributes.bgColors.red,
//                      green: ctx.attributes.bgColors.green,
//                      blue: ctx.attributes.bgColors.blue)
            }
            
        } dynamicIsland: { ctx in
            
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center) {
                        if let image = UIImage(data: ctx.attributes.icon) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 32, height: 32)
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
                
                if let image = UIImage(data: ctx.attributes.icon) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fit)
                }
            } compactTrailing: {
                Text(ctx.state.temperature)
                
            } minimal: {
                if let image = UIImage(data: ctx.attributes.icon) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            
        }
        
    }
}
