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
            Color(ColorConstants.main)

            HStack {
                Button("", systemImage: "location") {
                    backToCurrentLocation()
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                
                ZStack(alignment: .trailing) {
                    TextField(WeatherConstants.city, text: $searchCity)
                        .padding()
                        .background(.background)
                        .cornerRadius(10)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                        .shadow(radius: 1)
                        .onSubmit {
                            onSearch()
                        }
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

