//
//  ISO8601DateCoding.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension ISO8601DateFormatter: FormatterConverter { }

extension Hollow.DateFormat {
    public enum ISO8601Date: HollowValueProvider {
        public static let hasValue: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withInternetDateTime
            return formatter
        }()
    }
}

public typealias ISO8601DateCoding = DateFormatCoding<Hollow.DateFormat.ISO8601Date>
public typealias ISO8601DateDeoding = DateFormatterDecoding<Hollow.DateFormat.ISO8601Date>
public typealias ISO8601DateEnoding = DateFormatterEncoding<Hollow.DateFormat.ISO8601Date>
