//
//  AirQuality.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import Foundation
import SwiftUI

struct AirQuality: Decodable {
    let list: [AQList]
}

struct AQList: Decodable, Equatable {
    let main: AQMain
    let components: AQComponents
    let dt: Date
}

struct AQMain: Decodable, Equatable {
    let aqi: Int
}

struct AQComponents: Decodable, Equatable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}

struct AQResources {
    let aqList: AQList
    let category: AQICategory.Resources
}

enum AQICategory {
    case good, fair, moderate, poor, veryPoor

    struct Resources {
        let index: Int
        let description: String
        let longDescription: String
        let icon: Image
        let color: Color
    }
    
    static func categoryForIndex(_ index: Int) -> AQICategory {
        switch index {
        case 1: return .good
        case 2: return .fair
        case 3: return .moderate
        case 4: return .poor
        case 5...: return .veryPoor
        default: return .moderate
        }
    }
    
    var categoryResources: Resources {
        return Resources(index: index,
                         description: description,
                         longDescription: longDescription,
                         icon: icon,
                         color: color)
    }
    
    var index: Int {
        switch self {
        case .good:
            return 1
        case .fair:
            return 2
        case .moderate:
            return 3
        case .poor:
            return 4
        case .veryPoor:
            return 5
        }
    }
    
    var description: String {
        switch self {
        case .good:
            return WeatherConstants.good
        case .fair:
            return WeatherConstants.fair
        case .moderate:
            return WeatherConstants.moderate
        case .poor:
            return WeatherConstants.poor
        case .veryPoor:
            return WeatherConstants.veryPoor
        }
    }
    
    var longDescription: String {
        switch self {
        case .good:
            return WeatherConstants.goodLong
        case .fair:
            return WeatherConstants.fairLong
        case .moderate:
            return WeatherConstants.moderateLong
        case .poor:
            return WeatherConstants.poorLong
        case .veryPoor:
            return WeatherConstants.veryPoorLong
        }
    }
    
    var icon: Image {
        switch self {
        case .good:
            return Image(.good)
        case .fair:
            return Image(.fair)
        case .moderate:
            return Image(.moderate)
        case .poor:
            return Image(.poor)
        case .veryPoor:
            return Image(.veryPoor)
        }
    }
    
    var color: Color {
        switch self {
        case .good:
            return .green
        case .fair:
            return .green
        case .moderate:
            return .blue
        case .poor:
            return .orange
        case .veryPoor:
            return .red
        }
    }
}

enum Pollutant: Hashable, Comparable {
    case so2(Double)
    case no2(Double)
    case pm10(Double)
    case pm2_5(Double)
    case o3(Double)
    case co(Double)
    
    var description: String {
        switch self {
        case .so2(_):
            return WeatherConstants.so2
        case .no2(_):
            return WeatherConstants.no2
        case .pm10(_):
            return WeatherConstants.pm10
        case .pm2_5(_):
            return WeatherConstants.pm2_5
        case .o3(_):
            return WeatherConstants.o3
        case .co(_):
            return WeatherConstants.co
        }
    }

    func category() -> AQICategory {
        switch self {
        case .so2(let value):
            switch value {
            case 0..<20: return .good
            case 20..<80: return .fair
            case 80..<250: return .moderate
            case 250..<350: return .poor
            case 350...: return .veryPoor
            default: return .moderate
            }
        case .no2(let value):
            switch value {
            case 0..<40: return .good
            case 40..<70: return .fair
            case 70..<150: return .moderate
            case 150..<200: return .poor
            case 200...: return .veryPoor
            default: return .moderate
            }
        case .pm10(let value):
            switch value {
            case 0..<20: return .good
            case 20..<50: return .fair
            case 50..<100: return .moderate
            case 100..<200: return .poor
            case 200...: return .veryPoor
            default: return .moderate
            }
        case .pm2_5(let value):
            switch value {
            case 0..<10: return .good
            case 10..<25: return .fair
            case 25..<50: return .moderate
            case 50..<75: return .poor
            case 75...: return .veryPoor
            default: return .moderate
            }
        case .o3(let value):
            switch value {
            case 0..<60: return .good
            case 60..<100: return .fair
            case 100..<140: return .moderate
            case 140..<180: return .poor
            case 180...: return .veryPoor
            default: return .moderate
            }
        case .co(let value):
            switch value {
            case 0..<4400: return .good
            case 4400..<9400: return .fair
            case 9400..<12400: return .moderate
            case 12400..<15400: return .poor
            case 15400...: return .veryPoor
            default: return .moderate
            }
        }
    }
    
    static func < (lhs: Pollutant, rhs: Pollutant) -> Bool {
        return lhs.description < rhs.description
    }
}
