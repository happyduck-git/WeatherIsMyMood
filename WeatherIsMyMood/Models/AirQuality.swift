//
//  AirQuality.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import Foundation

struct AirQuality: Decodable {
    let list: [AQList]
}

struct AQList: Decodable {
    let main: AQMain
}

struct AQMain: Decodable {
    let aqi: Int
}
