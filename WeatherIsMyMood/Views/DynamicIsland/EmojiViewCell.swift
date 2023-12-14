//
//  EmojiViewCell.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import UIKit.UIImage

struct EmojiViewCell: View {
    @State var emojiData: Data
    private let width = (UIScreen.main.bounds.width - 50) / 5
    private let gradientBold: Color = .gray.opacity(0.4)
    
    var body: some View {
        ZStack(alignment: .center) {
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.clear)
                .background {
                    LinearGradient(colors: [gradientBold, .clear, gradientBold],
                                   startPoint: .top,
                                   endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            
            if let image = UIImage(data: emojiData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
            }
           
        }
        .frame(width: width, height: width)
    }
}
