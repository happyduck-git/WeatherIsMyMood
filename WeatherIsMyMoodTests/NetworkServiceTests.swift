//
//  NetworkManagerTests.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 2/28/24.
//

import XCTest
import Alamofire
@testable import WeatherIsMyMood

final class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkService!
    class MockNetworkManager: NetworkService {
        var session: Alamofire.Session
        var baseURL: String = "https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=123&lon=123&appid=12345"
        
        init(session: Alamofire.Session) {
            self.session = session
        }
    }
    
    override func setUpWithError() throws {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        networkManager = MockNetworkManager(session: Session(configuration: sessionConfig))
    }
    
    override func tearDownWithError() throws {
        networkManager = nil
    }
    
    func test_fetchData() async {
        MockURLProtocol.responseWithStatusCode(code: 200)
        MockURLProtocol.responseWithDTO(type: .aqi)
        let response: Result<AirQuality, AFError> = await networkManager.fetchData(urlString: networkManager.baseURL)
        switch response {
        case .success(let success):
            XCTAssertEqual(success.list.count, 2)
        case .failure(let failure):
            XCTFail("Fetch data failed with error-- \(failure)")
        }
    }
}

final class MockURLProtocol: URLProtocol {
    
    enum ResponseType {
        case error(Error)
        case success(HTTPURLResponse)
    }
    private(set) var activeTask: URLSessionTask?
    private lazy var session: URLSession = URLSession.shared
    static var responseType: ResponseType!
    static var dtoType: MockDTOType!
}

extension MockURLProtocol {
    
    enum MockError: Error {
        case none
    }
    
    static func responseWithFailure() {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.error(MockError.none)
    }
    
    static func responseWithStatusCode(code: Int) {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=123&lon=123&appid=12345")!, statusCode: code, httpVersion: nil, headerFields: nil)!)
    }
    
    static func responseWithDTO(type: MockDTOType) {
        MockURLProtocol.dtoType = type
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override func startLoading() {
        let response = setUpMockResponse()
        let data = setUpMockData()
        
        self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data!)
        self.client?.urlProtocolDidFinishLoading(self)
        activeTask = session.dataTask(with: request.urlRequest!)
        activeTask?.cancel()
    }
    
    
    private func setUpMockResponse() -> HTTPURLResponse? {
        var response: HTTPURLResponse?
        switch MockURLProtocol.responseType {
        case .error(let error)?:
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let newResponse)?:
            response = newResponse
        default:
            fatalError("No fake responses found.")
        }
        return response!
    }
    
    private func setUpMockData() -> Data? {
        let fileName: String = MockURLProtocol.dtoType.fileName
        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("FILE NOT FOUND")
            return Data()
        }
        
        return try? Data(contentsOf: file)
    }
    
    override func stopLoading() {
        activeTask?.cancel()
    }
}

extension MockURLProtocol {
    
    enum MockDTOType {
        case aqi
        
        var fileName: String {
            switch self {
            case .aqi: return "aqi_mock_response.json"
            }
        }
    }
    
}
