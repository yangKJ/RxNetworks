//
//  TimestampDateTransformer.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

/// Decodes String or TimeInterval values as an Since1970 time `Date`.
open class TimestampDateTransform: TransformType {
    
    public enum TimestampSince1970Type: TimeInterval {
        /// The interval is in seconds since midnight UTC on January 1st, 1970.
        case seconds = 1
        /// The interval is in milliseconds since midnight UTC on January 1st, 1970.
        case milliseconds = 1_000
        /// The interval is in microseconds since midnight UTC on January 1st, 1970.
        case microseconds = 1_000_000
        /// The interval is in nanoseconds since midnight UTC on January 1st, 1970.
        case nanoseconds = 1_000_000_000
    }
    
    public typealias Object = Date
    public typealias JSON = TimeInterval
    
    let type: TimestampSince1970Type
    
    public init(type: TimestampSince1970Type = .seconds) {
        self.type = type
    }
    
    open func transformFromJSON(_ value: Any) -> Date? {
        if let value = value as? TimeInterval {
            return Date(timeIntervalSince1970: value / type.rawValue)
        }
        if let value = value as? String ?? {
            Hollow.transfer2String(with: value)
        }() {
            let timeInterval = TimeInterval(atof(value)) / type.rawValue
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Date) -> TimeInterval? {
        return value.timeIntervalSince1970 * type.rawValue
    }
}
