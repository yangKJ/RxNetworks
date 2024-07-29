//
//  RFC3339DateFormatter.swift
//  CodableExample
//
//  Created by Condy on 2024/6/22.
//

import Foundation

extension Hollow.DateFormat {
    public enum RFC3339Date: DateConverter { }
}

/// Decodes String values as an RFC 3339 `Date`.
/// `@RFC3339DateCoding` decodes RFC 3339 date strings into `Date`s. 
/// Encoding the `Date` will encode the value back into the original string value.
extension Hollow.DateFormat.RFC3339Date {
    public static let hasValue: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
}
