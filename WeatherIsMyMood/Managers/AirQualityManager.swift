//
//  AirQualityManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 3/9/24.
//

import SwiftUI
import CoreLocation
import Alamofire

final class AirQualityManager: NetworkClient, ObservableObject {
    var session: Session
    var baseURL: String = "https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=%d&lon=%d&appid=\(EnvironmentConfig.openWeatherApiKey)"
    
    init(session: Session) {
        self.session = session
    }

}

extension AirQualityManager {
    /// Fetch air quality predictions
    /// - Parameter location: Current location
    /// - Returns: Air quality list
    private func fetchAirQualityPrediction(location: CLLocation) async -> [AQList] {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let urlString = String(format: self.baseURL, lat, lon)
        let result: Result<AirQuality, AFError> = await self.fetchData(urlString: urlString)
        
        switch result {
        case .success(let result):
            return result.list
        case .failure(let failure):
            #if DEBUG
            print("Error: -- \(failure)")
            #endif
            return []
        }
    }
}
