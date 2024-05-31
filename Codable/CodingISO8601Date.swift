//
//  CodingISO8601Date.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension ISO8601DateFormatter: FormatterConverter { }

extension Hollow.DateFormat {
    public enum ISO8601Date: HollowValue {
        public static let hasValue = ISO8601DateFormatter()
    }
}

public typealias CodingISO8601Date = CodingDateFormatter<Hollow.DateFormat.ISO8601Date>
