//
//  OnboardingView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/27/24.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("How to Add Widget")
            ZStack(alignment: .leading) {
                Image(.widgetAdd)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 200)
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Image(.arrowUp)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 20)
                        Text("Step2. Tap “+” button")
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "hand.tap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        Text("Step1. Tap and hold your wall paper\nuntil you see buttons\nat the top of the screen.")
                    }
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 0))
                }
            }
            HStack(alignment: .bottom) {
                
                Text("Step3.\n\"Search Weather Island\"")
                Image(.arrowDown)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 20)
            }
            Image(.widgetSearchEn)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 200)

            Text("Step4.\nSelect and add widget on you wallpaper!")
            HStack {
                Image(.widgetSmallEn)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Image(.widgetMidEn)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
            }
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
