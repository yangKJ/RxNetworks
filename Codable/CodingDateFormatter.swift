//
//  CodingDateFormatter.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public extension Hollow {
    struct DateFormat {
        public enum yyyy: HollowValue { public static let hasValue = "yyyy" }
        public enum yyyy_p_mm_p_dd: HollowValue { public static let hasValue = "yyyy.MM.dd" }
        public enum mm_p_dd: HollowValue { public static let hasValue = "MM.dd" }
        public enum yyyy_p_mm: HollowValue { public static let hasValue = "yyyy.MM" }
        public enum yyyy_p_mm_p_dd_hh_mm: HollowValue { public static let hasValue = "yyyy.MM.dd HH:mm" }
        public enum yyyy_mm: HollowValue { public static let hasValue = "yyyyMM" }
        public enum yyyy_mm_dd: HollowValue { public static let hasValue = "yyyy-MM-dd" }
        public enum yyyy_virgule_mm_virgule_dd: HollowValue { public static let hasValue = "yyyy/MM/dd" }
        public enum mm_dd: HollowValue { public static let hasValue = "MM-dd" }
        public enum mmdd: HollowValue { public static let hasValue = "MMdd" }
        public enum yymm: HollowValue { public static let hasValue = "yyMM" }
        public enum yyyymmdd: HollowValue { public static let hasValue = "yyyyMMdd" }
        public enum yyyymmddhhkmmss: HollowValue { public static let hasValue = "yyyyMMddHHmmss" }
        public enum yyyy_mm_dd_CH: HollowValue { public static let hasValue = "yyyy年MM月dd日" }
        public enum yyyy_m_d_CH: HollowValue { public static let hasValue = "yyyy年M月d日" }
        public enum yyyy_mm_dd_hh_mm_ss_CH: HollowValue { public static let hasValue = "yyyy年MM月dd日 HH:mm:ss" }
        public enum mm_dd_hh_mm_ss_CH: HollowValue { public static let hasValue = "MM月dd日 HH:mm:ss" }
        public enum yyyym_CH: HollowValue { public static let hasValue = "yyyy年M月" }
        public enum yyyy_mm_dd_hh_mm: HollowValue { public static let hasValue = "yyyy-MM-dd HH:mm" }
        public enum yyyy_mm_dd_hh_mm_ss: HollowValue { public static let hasValue = "yyyy-MM-dd HH:mm:ss" }
    }
}

public protocol FormatterConverter {
    func string(from date: Date) -> String
    func date(from string: String) -> Date?
}

extension DateFormatter: FormatterConverter { }

/// If you want to use it like this: `@CodingDateFormatter<Hollow.DateFormat.yyyy_mm_dd>`
public typealias CodingDateFormatter<T: HollowValue> = CodableDateFormatter<T,T>

/// If you want to use it like this: `@CodableDateFormatter<Hollow.DateFormat.yyyy_mm_dd_hh_mm_ss, Hollow.DateFormat.yyyy_mm_dd_hh_mm_ss_CH>`
@propertyWrapper public struct CodableDateFormatter<D: HollowValue, E: HollowValue>: Codable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        if let timeInterval = try? TimeInterval(from: decoder) {
            self.wrappedValue = Self.decodableDateFormatter?.date(from: "\(timeInterval)")
        } else if let dateString = try? String(from: decoder) {
            self.wrappedValue = Self.decodableDateFormatter?.date(from: dateString)
        } else {
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue, let dateFormatter = Self.encodableDateFormatter {
            try container.encode(dateFormatter.string(from: date))
        } else {
            try container.encodeNil()
        }
    }
    
    private static var decodableDateFormatter: FormatterConverter? {
        if let formatter = D.hasValue as? FormatterConverter {
            return formatter
        }
        guard let string = D.hasValue as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans-CN")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = string
        return formatter
    }
    
    private static var encodableDateFormatter: FormatterConverter? {
        if let formatter = E.hasValue as? FormatterConverter {
            return formatter
        }
        guard let string = E.hasValue as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans-CN")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = string
        return formatter
    }
}
