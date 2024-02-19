//
//  WeatherConditionInfo+CoreDataClass.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/16/24.
//
//

import Foundation
import CoreData

@objc(WeatherConditionInfo)
public class WeatherConditionInfo: NSManagedObject {

}

struct WeatherContent {
    var name: String
    var imageData: Data?
}
