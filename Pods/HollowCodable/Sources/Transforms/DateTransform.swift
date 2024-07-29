//
//  DateTransform.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

/// Supports the use of different encoders and decoders.
open class DateTransform<Decoding: DateConverter, Encoding: DateConverter>: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() { }
    
    open func transformFromJSON(_ value: Any) -> Date? {
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        return Decoding.transformFromValue(with: string)
    }
    
    open func transformToJSON(_ value: Date) -> String? {
        Encoding.transformToValue(with: value)
    }
}
