//
//  Color+Extension.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI

extension Color {
    init(red: Int, green: Int, blue: Int) {
        self = Color(red: Double(red)/255, green: Double(green)/255, blue: Double(blue)/255)
    }
}
