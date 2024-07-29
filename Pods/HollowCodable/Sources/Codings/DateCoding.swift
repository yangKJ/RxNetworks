//
//  DateCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

public typealias DateValue2<T: DateConverter> = DateValue<T,T>

/// Decodes and encodes dates using a strategy type.
/// `@DateCoding` decodes dates using a `DateConverter` which provides custom decoding and encoding functionality.
public struct DateValue<D: DateConverter, E: DateConverter>: Transformer {
    
    var dateString: String?
    
    public typealias DecodeType = Date
    public typealias EncodeType = String
    
    public init?(value: Any) {
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        self.dateString = string
    }
    
    public func transform() throws -> Date? {
        guard let dateString = dateString else {
            throw HollowError.dateToString
        }
        return D.transformFromValue(with: dateString)
    }
    
    public static func transform(from value: Date) throws -> String {
        guard let string = E.transformToValue(with: value) else {
            throw HollowError.dateToString
        }
        return string
    }
}

extension DateValue: DefaultValueProvider {
    
    public static var hasDefaultValue: Date {
        Date.hasDefaultValue
    }
}
