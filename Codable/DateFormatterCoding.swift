//
//  DateFormatterCoding.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public extension Hollow {
    struct DateFormat {
        public enum yyyy: HollowValueProvider { public static let hasValue = "yyyy" }
        public enum yyyy_p_mm_p_dd: HollowValueProvider { public static let hasValue = "yyyy.MM.dd" }
        public enum mm_p_dd: HollowValueProvider { public static let hasValue = "MM.dd" }
        public enum yyyy_p_mm: HollowValueProvider { public static let hasValue = "yyyy.MM" }
        public enum yyyy_p_mm_p_dd_hh_mm: HollowValueProvider { public static let hasValue = "yyyy.MM.dd HH:mm" }
        public enum yyyy_mm: HollowValueProvider { public static let hasValue = "yyyyMM" }
        public enum yyyy_mm_dd: HollowValueProvider { public static let hasValue = "yyyy-MM-dd" }
        public enum yyyy_virgule_mm_virgule_dd: HollowValueProvider { public static let hasValue = "yyyy/MM/dd" }
        public enum mm_dd: HollowValueProvider { public static let hasValue = "MM-dd" }
        public enum mmdd: HollowValueProvider { public static let hasValue = "MMdd" }
        public enum yymm: HollowValueProvider { public static let hasValue = "yyMM" }
        public enum yyyymmdd: HollowValueProvider { public static let hasValue = "yyyyMMdd" }
        public enum yyyymmddhhkmmss: HollowValueProvider { public static let hasValue = "yyyyMMddHHmmss" }
        public enum yyyy_mm_dd_CH: HollowValueProvider { public static let hasValue = "yyyy年MM月dd日" }
        public enum yyyy_m_d_CH: HollowValueProvider { public static let hasValue = "yyyy年M月d日" }
        public enum yyyy_mm_dd_hh_mm_ss_CH: HollowValueProvider { public static let hasValue = "yyyy年MM月dd日 HH:mm:ss" }
        public enum mm_dd_hh_mm_ss_CH: HollowValueProvider { public static let hasValue = "MM月dd日 HH:mm:ss" }
        public enum yyyym_CH: HollowValueProvider { public static let hasValue = "yyyy年M月" }
        public enum yyyy_mm_dd_hh_mm: HollowValueProvider { public static let hasValue = "yyyy-MM-dd HH:mm" }
        public enum yyyy_mm_dd_hh_mm_ss: HollowValueProvider { public static let hasValue = "yyyy-MM-dd HH:mm:ss" }
    }
}

extension DateFormatter: FormatterConverter { }

/// If you want to use it like this: `@DateFormatterCoding<Hollow.DateFormat.yyyy, Hollow.DateFormat.yyyym_CH>`
@propertyWrapper public struct DateFormatterCoding<D: HollowValueProvider, E: HollowValueProvider>: Codable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try DateFormatterDecoding<D>(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try DateFormatterEncoding<E>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct DateFormatterDecoding<T: HollowValueProvider>: Decodable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        if let timeInterval = try? TimeInterval(from: decoder) {
            self.wrappedValue = Self.decodableFormatter?.date(from: "\(timeInterval)")
        } else if let dateString = try? String(from: decoder) {
            self.wrappedValue = Self.decodableFormatter?.date(from: dateString)
        } else {
            self.wrappedValue = nil
        }
    }
    
    private static var decodableFormatter: FormatterConverter? {
        if let formatter = T.hasValue as? FormatterConverter {
            return formatter
        }
        guard let string = T.hasValue as? String else {
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

@propertyWrapper public struct DateFormatterEncoding<T: HollowValueProvider>: Encodable {
    
    public let wrappedValue: Date?
    
    public init(_ wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue, let dateFormatter = Self.encodableFormatter {
            try container.encode(dateFormatter.string(from: date))
        } else {
            try container.encodeNil()
        }
    }
    
    private static var encodableFormatter: FormatterConverter? {
        if let formatter = T.hasValue as? FormatterConverter {
            return formatter
        }
        guard let string = T.hasValue as? String else {
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
