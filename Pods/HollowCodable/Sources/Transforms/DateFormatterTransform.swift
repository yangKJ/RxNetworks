//
//  DateFormatterTransform.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

open class DateFormatterTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public let dateFormatter: DateFormatter
    
    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    open func transformFromJSON(_ value: Any) -> Date? {
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        return dateFormatter.date(from: string)
    }
    
    open func transformToJSON(_ value: Date) -> String? {
        dateFormatter.string(from: value)
    }
}
