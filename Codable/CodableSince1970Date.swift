//
//  CodableSince1970Date.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct Interval: Decodable {
    /// The interval is in seconds since
    /// midnight UTC on January 1st, 1970.
    public enum seconds: DateFormatValue { public static let formatValue = 1 }
    /// The interval is in milliseconds since
    /// midnight UTC on January 1st, 1970.
    public enum milliseconds: DateFormatValue { public static let formatValue = 1_000 }
    /// The interval is in microseconds since
    /// midnight UTC on January 1st, 1970.
    public enum microseconds: DateFormatValue { public static let formatValue = 1_000_000 }
    /// The interval is in nanoseconds since
    /// midnight UTC on January 1st, 1970.
    public enum nanoseconds: DateFormatValue { public static let formatValue = 1_000_000_000 }
}

/// If you want to use it like this: `@CodableSince1970Date<Interval.milliseconds>`
@propertyWrapper public struct CodableSince1970Date<T: DateFormatValue>: Codable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        if let timeInterval = try? TimeInterval(from: decoder) {
            self.wrappedValue = Date(timeIntervalSince1970: timeInterval / Self.val)
        } else if let timeString = try? String(from: decoder) {
            let timeInterval = TimeInterval(atof(timeString))
            self.wrappedValue = Date(timeIntervalSince1970: timeInterval / Self.val)
        } else {
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue {
            try container.encode(date.timeIntervalSince1970 * Self.val)
        } else {
            try container.encodeNil()
        }
    }
    
    private static var val: TimeInterval {
        guard let val = T.formatValue as? Int else {
            return 1
        }
        return TimeInterval(val)
    }
}
