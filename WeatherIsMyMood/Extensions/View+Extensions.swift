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

extension View {
    
    /// Modifier for building different views per os version.
    /// - Parameter _: View to build.
    /// - Returns: Built view.
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

extension Scene {
    func modify<Content: Scene>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
