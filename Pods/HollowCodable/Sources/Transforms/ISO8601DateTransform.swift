//
//  ISO8601DateTransform.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

/// Decodes String values as an ISO8601 `Date`.
/// Encoding the `Date` will encode the value into the original string value.
open class ISO8601DateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() { }
    
    open func transformFromJSON(_ value: Any) -> Date? {
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        let formatter = Hollow.DateFormat.ISO8601Date.hasValue
        return formatter.date(from: string)
    }
    
    open func transformToJSON(_ value: Date) -> String? {
        let formatter = Hollow.DateFormat.ISO8601Date.hasValue
        return formatter.string(from: value)
    }
}
