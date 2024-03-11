//
//  NetworkService.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import Foundation
import Alamofire

protocol NetworkService {
    var session: Session { get }
    var baseURL: String { get }
    func request(urlString: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) -> DataRequest
    func fetchData<T: Decodable>(urlString: String) async -> Result<T, AFError>
}

extension NetworkService {

    func request(urlString: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> DataRequest {
        return session.request(urlString,
                           method: method,
                           parameters: parameters,
                           encoding: URLEncoding.default,
                           headers: headers,
                           interceptor: nil,
                           requestModifier: nil)
    }
    
    func fetchData<T: Decodable>(urlString: String) async -> Result<T, AFError> {
        let request = request(urlString: urlString, method: .get)
        
        return await request
            .validate()
            .serializingDecodable(T.self)
            .result
    }
    
}


