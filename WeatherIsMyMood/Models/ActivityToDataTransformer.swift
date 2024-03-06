//
//  ActivityToDataTransformer.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 3/6/24.
//

import Foundation
import ActivityKit

class ActivityToDataTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return Activity<WeatherAttributes>.self
    }
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [Activity<WeatherAttributes>.self]
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let color = value as? Activity<WeatherAttributes> else {
            fatalError("Wrong data type: value must be a UIColor object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(color)
    }
}

extension NSValueTransformerName {
    static let activityToDataTransformer = NSValueTransformerName(rawValue: "ActivityToDataTransformer")
}
