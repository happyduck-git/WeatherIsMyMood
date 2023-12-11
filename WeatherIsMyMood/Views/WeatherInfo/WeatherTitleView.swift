//
//  WeatherTitleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI

struct WeatherTitleView: View {
    let title: String
    
    var body: some View {
        ZStack(alignment: .center) {
            Capsule(style: .continuous)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 190))
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(height: 50)
                
            Text(self.title)
                .font(.title3)
                .foregroundStyle(.black)
                .opacity(0.7)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 200))
        }
    }
}

#Preview {
    WeatherTitleView(title: "Hourly Weather")
}
