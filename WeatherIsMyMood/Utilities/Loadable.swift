//
//  Loadable.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 3/11/24.
//

import SwiftUI

enum LoadStatus {
    case notRequested
    case loaded
    case failed(Error)

    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
}
