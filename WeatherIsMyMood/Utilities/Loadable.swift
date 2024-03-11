//
//  Loadable.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 3/11/24.
//

import SwiftUI

enum Loadable<T> {
    case notRequested
    case isLoading
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        default: return nil
        }
    }
    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
}
