//
//  RFC2822DateFormatter.swift
//  CodableExample
//
//  Created by Condy on 2024/6/22.
//

import Foundation

extension Hollow.DateFormat {
    public enum RFC2822Date: DateConverter { }
}

/// Decodes String values as an RFC 2822 `Date`.
/// `@RFC2822DateCoding` decodes RFC 2822 date strings into `Date`s. 
/// Encoding the `Date` will encode the value back into the original string value.
extension Hollow.DateFormat.RFC2822Date {
    public static let hasValue: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, d MMM y HH:mm:ss zzz"
        return dateFormatter
    }()
}

extension DateConverter where Self.Value == DateFormatter {
    
    public static func transformToValue(with value: Date) -> String? {
        hasValue.string(from: value)
    }
    
    public static func transformFromValue(with value: String) -> Date? {
        hasValue.date(from: value)
    }
}
