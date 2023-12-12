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
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherAttributes.self) { ctx in
            // Lock screen widget part.
            
        } dynamicIsland: { ctx in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
//                    if let image = UIImage(data: ctx.state.icon) {
//                        Image(uiImage: image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    }
                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text(ctx.state.temperature)
//                        .padding()
//                }
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
