//
//  LoadingView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/12/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.2)
            
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.orange)
                .scaleEffect(2)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
