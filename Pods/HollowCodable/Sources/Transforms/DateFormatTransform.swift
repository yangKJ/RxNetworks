//
//  CustomDateFormatTransform.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

public final class CustomDateFormatTransform: DateFormatterTransform {

    public init(formatString: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans-CN")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = formatString
        super.init(dateFormatter: formatter)
    }
}

/// Decodes String values as an RFC 2822 `Date`.
/// Encoding the `Date` will encode the value back into the original string value.
public final class RFC2822DateTransform: DateFormatterTransform {
    
    public init() {
        let dateFormatter = Hollow.DateFormat.RFC2822Date.hasValue
        super.init(dateFormatter: dateFormatter)
    }
}

/// Decodes String values as an RFC 3339 `Date`.
/// Encoding the `Date` will encode the value back into the original string value.
public final class RFC3339DateTransform: DateFormatterTransform {
    
    public init() {
        let dateFormatter = Hollow.DateFormat.RFC3339Date.hasValue
        super.init(dateFormatter: dateFormatter)
    }
}
