//
//  Since1970DateCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public extension Hollow {
    struct Interval {
        /// The interval is in seconds since midnight UTC on January 1st, 1970.
        public enum seconds: HollowValue { public static let hasValue: TimeInterval = 1 }
        /// The interval is in milliseconds since midnight UTC on January 1st, 1970.
        public enum milliseconds: HollowValue { public static let hasValue: TimeInterval = 1_000 }
        /// The interval is in microseconds since midnight UTC on January 1st, 1970.
        public enum microseconds: HollowValue { public static let hasValue: TimeInterval = 1_000_000 }
        /// The interval is in nanoseconds since midnight UTC on January 1st, 1970.
        public enum nanoseconds: HollowValue { public static let hasValue: TimeInterval = 1_000_000_000 }
    }
}

/// If you want to use it like this: `@Since1970DateCoding<Hollow.Interval.milliseconds>`
@propertyWrapper public struct Since1970DateCoding<D: HollowValue, E: HollowValue>: Codable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try Since1970DateDecoding<D>(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try Since1970DateEncoding<E>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct Since1970DateDecoding<T: HollowValue>: Decodable {
    
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
    
    static var val: TimeInterval {
        guard let val = T.hasValue as? TimeInterval else {
            return 1.0
        }
        return val
    }
}

@propertyWrapper public struct Since1970DateEncoding<T: HollowValue>: Encodable {
    
    public let wrappedValue: Date?
    
    public init(_ wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue {
            try container.encode(date.timeIntervalSince1970 * Self.val)
        } else {
            try container.encodeNil()
        }
    }
    
    static var val: TimeInterval {
        guard let val = T.hasValue as? TimeInterval else {
            return 1.0
        }
        return val
    }
}
