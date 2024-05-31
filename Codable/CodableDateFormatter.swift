//
//  CodableDateFormatter.swift
//  Booming
//
//  Created by Condy on 2024/5/31.
//

import Foundation

public protocol DateFormatValue {
    associatedtype Value: Decodable
    static var formatValue: Value { get }
}

public struct DateFormat: Decodable {
    public enum yyyy: DateFormatValue { public static let formatValue = "yyyy" }
    public enum yyyy_p_mm_p_dd: DateFormatValue { public static let formatValue = "yyyy.MM.dd" }
    public enum mm_p_dd: DateFormatValue { public static let formatValue = "MM.dd" }
    public enum yyyy_p_mm: DateFormatValue { public static let formatValue = "yyyy.MM" }
    public enum yyyy_p_mm_p_dd_hh_mm: DateFormatValue { public static let formatValue = "yyyy.MM.dd HH:mm" }
    public enum yyyy_mm: DateFormatValue { public static let formatValue = "yyyyMM" }
    public enum yyyy_mm_dd: DateFormatValue { public static let formatValue = "yyyy-MM-dd" }
    public enum yyyy_virgule_mm_virgule_dd: DateFormatValue { public static let formatValue = "yyyy/MM/dd" }
    public enum mm_dd: DateFormatValue { public static let formatValue = "MM-dd" }
    public enum mmdd: DateFormatValue { public static let formatValue = "MMdd" }
    public enum yymm: DateFormatValue { public static let formatValue = "yyMM" }
    public enum yyyymmdd: DateFormatValue { public static let formatValue = "yyyyMMdd" }
    public enum yyyymmddhhkmmss: DateFormatValue { public static let formatValue = "yyyyMMddHHmmss" }
    public enum yyyy_mm_dd_CH: DateFormatValue { public static let formatValue = "yyyy年MM月dd日" }
    public enum yyyy_m_d_CH: DateFormatValue { public static let formatValue = "yyyy年M月d日" }
    public enum yyyy_mm_dd_hh_mm_ss_CH: DateFormatValue { public static let formatValue = "yyyy年MM月dd日 HH:mm:ss" }
    public enum mm_dd_hh_mm_ss_CH: DateFormatValue { public static let formatValue = "MM月dd日 HH:mm:ss" }
    public enum yyyym_CH: DateFormatValue { public static let formatValue = "yyyy年M月" }
    public enum yyyy_mm_dd_hh_mm: DateFormatValue { public static let formatValue = "yyyy-MM-dd HH:mm" }
    public enum yyyy_mm_dd_hh_mm_ss: DateFormatValue { public static let formatValue = "yyyy-MM-dd HH:mm:ss" }
}

/// If you want to use it like this: `@CodableDateFormatter<DateFormat.yyyy_mm_dd_hh_mm_ss>`
@propertyWrapper public struct CodableDateFormatter<T: DateFormatValue>: Codable {
    
    public let wrappedValue: Date?
    
    public init(from decoder: Decoder) throws {
        if let timeInterval = try? TimeInterval(from: decoder) {
            self.wrappedValue = Self.dateFormatter(with: T.formatValue)?.date(from: "\(timeInterval)")
        } else if let dateString = try? String(from: decoder) {
            self.wrappedValue = Self.dateFormatter(with: T.formatValue)?.date(from: dateString)
        } else {
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue, let dateFormatter = Self.dateFormatter(with: T.formatValue) {
            try container.encode(dateFormatter.string(from: date))
        } else {
            try container.encodeNil()
        }
    }
    
    private static func dateFormatter(with value: T.Value) -> DateFormatter? {
        guard let string = value as? String else {
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
