//
//  ISO8601DateCoding.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Hollow.DateFormat {
    public enum ISO8601Date: DateConverter { }
}

/// Decodes String values as an ISO8601 `Date`.
/// `@ISO8601DateCoding` relies on an `ISO8601DateFormatter` in order to decode `String` values into `Date`s.
/// Encoding the `Date` will encode the value into the original string value.
extension Hollow.DateFormat.ISO8601Date {
    public static let hasValue: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
}

extension DateConverter where Self.Value == ISO8601DateFormatter {
    
    public static func transformToValue(with value: Date) -> String? {
        hasValue.string(from: value)
    }
    
    public static func transformFromValue(with value: String) -> Date? {
        hasValue.date(from: value)
    }
}
