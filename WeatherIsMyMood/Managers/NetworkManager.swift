//
//  NetworkManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/18/24.
//

import Foundation
import Alamofire

protocol NetworkClient {
    func request(urlString: String, method: HTTPMethod) -> DataRequest
    func fetchData<T: Decodable>(urlString: String) async -> Result<T, AFError>
}

protocol AlamofirePrototype {
    typealias RequestModifier = (inout URLRequest) throws -> Void
    func request(_ convertible: URLConvertible,
                 method: HTTPMethod,
                 parameters: Parameters?,
                 encoding: ParameterEncoding,
                 headers: HTTPHeaders?,
                 interceptor: RequestInterceptor?,
                 requestModifier: RequestModifier?) -> DataRequest
}

extension Session: AlamofirePrototype {}

struct NetworkManager: NetworkClient {
    let alamofire: AlamofirePrototype
    
    func request(urlString: String, method: HTTPMethod) -> DataRequest {
        return alamofire.request(urlString,
                           method: method,
                           parameters: nil,
                           encoding: URLEncoding.default,
                           headers: nil,
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


