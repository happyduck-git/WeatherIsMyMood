//
//  SearchView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/10/23.
//

import SwiftUI

struct SearchView: View {
    
    @Binding var searchCity: String
    var onSearch: () -> Void
    var backToCurrentLocation: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.main

            HStack {
                Button("", systemImage: "location") {
                    backToCurrentLocation()
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                
                ZStack(alignment: .trailing) {
                    TextField("City", text: $searchCity)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                        .shadow(radius: 1)
                    Button("",
                           systemImage: "magnifyingglass.circle.fill")
                    {
                        onSearch()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}
