//
//  LoadingView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.2)
            
            LottieView(animation: .named("sun_color"))
                .looping()
                .resizable()
                .frame(width: 120, height: 120)

        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
