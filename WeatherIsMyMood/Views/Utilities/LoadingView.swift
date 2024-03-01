//
//  LoadingView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    
    private let filename: String?
    //MARK: - Init
    init(filename: String? = nil) {
        self.filename = filename
    }
    //MARK: - View
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.3)
            
            if let filename {
                LottieView(animation: .named(filename))
                    .looping()
                    .resizable()
                    .frame(width: 120, height: 120)
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
