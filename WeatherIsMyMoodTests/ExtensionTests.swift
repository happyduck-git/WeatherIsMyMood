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
    
    func test_roundDecimalPlace_ShouldReturnTrue() {
        let decimalString: String = "0.9871728"
        let convertedStr = decimalString.roundDecimalPlace(to: 3)
        XCTAssertEqual(convertedStr, "0.987")
    }

    func test_convertToTempFormat() {
        let tempDouble: Double = -0.0171728
        let convertedStr = tempDouble.convertToTempFormat(decimal: 1)
        XCTAssertEqual(convertedStr, "0.0")
        XCTAssertNotEqual(convertedStr, "-0.0")
        
        let tempDouble2: Double = -0.0971728
        let convertedStr2 = tempDouble2.convertToTempFormat(decimal: 1)
        XCTAssertEqual(convertedStr2, "-0.1")
        XCTAssertNotEqual(convertedStr2, "0.1")
    }
}

/// String Extensions
extension ExtensionTests {
    func test_camelCaseToSnakeCase() {
        let str = "partlyCloudy"
        let converted = str.camelCaseToSnakeCase()
        XCTAssertEqual(converted, "partly cloudy", "Converted string is not equal to expected string.")
        
        let str2 = "cloudy"
        let converted2 = str2.camelCaseToSnakeCase()
        XCTAssertEqual(converted2, "cloudy", "Converted string is not equal to expected string.")
    }
    
    func test_roundDecimalPlace() {
        let doubleStr = "0.92839491"
        XCTAssertEqual(doubleStr.roundDecimalPlace(to: 2), "0.93", "Converted string is not equal to expected string.")
        
        let wrongDouble = "not_double"
        XCTAssertEqual(wrongDouble.roundDecimalPlace(to: 1), wrongDouble, "Converted string is not equal to expected string.")
    }
    
    func test_addTemparatureUnit() {
        let str = "15"
        XCTAssertEqual(str.addTemparatureUnit(), "15˚", "Converted string is not equal to expected string.")
    }
}
