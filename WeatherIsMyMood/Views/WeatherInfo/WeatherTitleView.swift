//
//  WeatherTitleView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI

struct WeatherTitleView: View {
    
    let section: WeatherViewSection
    
    var body: some View {
        ZStack(alignment: .center) {
            Capsule(style: .continuous)
                .foregroundStyle(.background)
                .opacity(0.2)
                .frame(height: 50)

            HStack {
                Image(systemName: self.section.icon)
                    .foregroundStyle(self.section.color)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
                
                Text(self.section.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
                
                Spacer()
            }
        }
    }
}

#Preview {
    WeatherTitleView(section: .precipitation)
}
