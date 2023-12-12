//
//  View+Extensions.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/13/23.
//

import SwiftUI

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}
