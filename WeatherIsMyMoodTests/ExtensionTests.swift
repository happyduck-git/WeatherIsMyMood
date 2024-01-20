//
//  ExtensionTests.swift
//  WeatherIsMyMoodTests
//
//  Created by HappyDuck on 1/21/24.
//

import XCTest
@testable import WeatherIsMyMood

final class ExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_roundDecimalPlace_ShouldReturnTrue() throws {
        let decimalString: String = "0.9871728"
        let convertedStr = decimalString.roundDecimalPlace(to: 3)
        XCTAssertEqual(convertedStr, "0.987")
    }

}
