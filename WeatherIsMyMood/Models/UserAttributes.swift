//
//  UserAttributes.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/27/24.
//

import SwiftUI

struct UserAttributes: Codable {
    var backgroundColor: Color
    var textColor: Color
    var icon: Data?
    
    init(backgroundColor: Color, textColor: Color, icon: Data? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.icon = icon
    }
}

extension UserAttributes: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(UserAttributes.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "no-user-attribute"
        }
        return result
    }
}
