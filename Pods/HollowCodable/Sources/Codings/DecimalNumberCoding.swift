//
//  DecimalNumberCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

/// `@DecimalNumberCoding` decoding the `String`、`Double`、`Float`、`CGFloat`、`Int` or `Int64` to a NSDecimalNumber property.
public struct DecimalNumberValue: Transformer {
    
    let decimalString: String
    
    public typealias DecodeType = NSDecimalNumber
    public typealias EncodeType = String
    
    public init?(value: Any) {
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        self.decimalString = string
    }
    
    public func transform() throws -> NSDecimalNumber? {
        guard decimalString.hc.isValidDecimal else {
            return nil
        }
        let decimal = NSDecimalNumber(string: decimalString)
        if decimal.isEqual(to: NSDecimalNumber.notANumber) {
            return nil
        }
        return decimal
    }
    
    public static func transform(from value: NSDecimalNumber) throws -> String {
        value.description
    }
}

extension DecimalNumberValue: DefaultValueProvider {
    
    public static var hasDefaultValue: NSDecimalNumber {
        .zero
    }
}
