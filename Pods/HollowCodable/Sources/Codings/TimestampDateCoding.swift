//
//  Since1970DateCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Hollow {
    public struct Timestamp {
        public let intervalTime: TimeInterval
        public init(_ interval: TimeInterval) {
            self.intervalTime = interval
        }
    }
}

public extension Hollow.Timestamp {
    /// The interval is in seconds since midnight UTC on January 1st, 1970.
    enum secondsSince1970: DateConverter { public static let hasValue = Hollow.Timestamp(1) }
    /// The interval is in milliseconds since midnight UTC on January 1st, 1970.
    enum millisecondsSince1970: DateConverter { public static let hasValue = Hollow.Timestamp(1_000) }
    /// The interval is in microseconds since midnight UTC on January 1st, 1970.
    enum microsecondsSince1970: DateConverter { public static let hasValue = Hollow.Timestamp(1_000_000) }
    /// The interval is in nanoseconds since midnight UTC on January 1st, 1970.
    enum nanosecondsSince1970: DateConverter { public static let hasValue = Hollow.Timestamp(1_000_000_000) }
}

extension DateConverter where Self.Value == Hollow.Timestamp {
    
    public static func transformToValue(with value: Date) -> String? {
        String(describing: value.timeIntervalSince1970 * hasValue.intervalTime)
    }
    
    public static func transformFromValue(with value: String) -> Date? {
        let timeInterval = TimeInterval(atof(value)) / hasValue.intervalTime
        return Date(timeIntervalSince1970: timeInterval)
    }
}
