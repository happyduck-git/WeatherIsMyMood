//
//  EmojiViewCell.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI

struct EmojiViewCell: View {
    @State var emojiName: String
    private let width = (UIScreen.main.bounds.width - 50) / 5
    
    var body: some View {
        ZStack(alignment: .center) {
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.clear)
                .background(content: {
                    LinearGradient(colors: [.white, .clear, .white],
                                   startPoint: .topLeading,
                                   endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                })
                
            Image(emojiName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        .frame(width: width, height: width)
    }
}

#Preview {
    EmojiViewCell(emojiName: "clear_cloudy")
}
