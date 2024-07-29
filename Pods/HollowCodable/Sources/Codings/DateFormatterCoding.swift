//
//  DateFormatterCoding.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Hollow {
    public struct DateFormat {
        public let formatString: String
        public init(_ string: String) {
            self.formatString = string
        }
    }
}

public extension Hollow.DateFormat {
    enum yyyy: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy") }
    enum yyyy_p_mm_p_dd: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy.MM.dd") }
    enum mm_p_dd: DateConverter { public static let hasValue = Hollow.DateFormat("MM.dd") }
    enum yyyy_p_mm: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy.MM") }
    enum yyyy_p_mm_p_dd_hh_mm: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy.MM.dd HH:mm") }
    enum yyyy_mm: DateConverter { public static let hasValue = Hollow.DateFormat("yyyyMM") }
    enum yyyy_mm_dd: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy-MM-dd") }
    enum yyyy_virgule_mm_virgule_dd: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy/MM/dd") }
    enum mm_dd: DateConverter { public static let hasValue = Hollow.DateFormat("MM-dd") }
    enum mmdd: DateConverter { public static let hasValue = Hollow.DateFormat("MMdd") }
    enum yymm: DateConverter { public static let hasValue = Hollow.DateFormat("yyMM") }
    enum yyyymmdd: DateConverter { public static let hasValue = Hollow.DateFormat("yyyyMMdd") }
    enum yyyymmddhhkmmss: DateConverter { public static let hasValue = Hollow.DateFormat("yyyyMMddHHmmss") }
    enum yyyy_mm_dd_CH: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy年MM月dd日") }
    enum yyyy_m_d_CH: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy年M月d日") }
    enum yyyy_mm_dd_hh_mm_ss_CH: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy年MM月dd日 HH:mm:ss") }
    enum mm_dd_hh_mm_ss_CH: DateConverter { public static let hasValue = Hollow.DateFormat("MM月dd日 HH:mm:ss") }
    enum yyyym_CH: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy年M月") }
    enum yyyy_mm_dd_hh_mm: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy-MM-dd HH:mm") }
    enum yyyy_mm_dd_hh_mm_ss: DateConverter { public static let hasValue = Hollow.DateFormat("yyyy-MM-dd HH:mm:ss") }
}

extension DateConverter where Self.Value == Hollow.DateFormat {
    
    public static func transformToValue(with value: Date) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans-CN")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = hasValue.formatString
        return formatter.string(from: value)
    }
    
    public static func transformFromValue(with value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans-CN")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = hasValue.formatString
        return formatter.date(from: value)
    }
}
