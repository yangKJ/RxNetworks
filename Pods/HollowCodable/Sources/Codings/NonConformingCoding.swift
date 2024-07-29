//
//  NonConformingCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/12.
//

import Foundation

/// A provider for the data needed for (de)serializing non conforming floating point values
public protocol NonConformingDecimalValueProvider {
    /// The seralized `String` value to use when a number of `infiniti`
    static var positiveInfinity: String { get }
    /// The seralized `String` value to use when a number of `-infiniti`
    static var negativeInfinity: String { get }
    /// The seralized `String` value to use when a number of `NaN`
    static var nan: String { get }
}

public typealias NonConformingFloatValue<T: NonConformingDecimalValueProvider> = NonConformingValue<T, Float>
public typealias NonConformingDoubleValue<T: NonConformingDecimalValueProvider> = NonConformingValue<T, Double>

/// Uses the `ValueProvider` for (de)serialization of a non-conforming `Floating`.
public struct NonConformingValue<ValueProvider: NonConformingDecimalValueProvider, Floating: FloatingPoint>: Transformer where Floating: Codable & LosslessStringConvertible {
    
    let value: Floating
    
    public typealias DecodeType = Floating
    public typealias EncodeType = String
    
    public init?(value: Any) {
        if let value = value as? Floating {
            self.value = value
            return
        }
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        switch string {
        case ValueProvider.positiveInfinity:
            self.value = .infinity
        case ValueProvider.negativeInfinity:
            self.value = -.infinity
        case ValueProvider.nan:
            self.value = .nan
        default:
            guard let value = Floating(string) else {
                return nil
            }
            self.value = value
        }
    }
    
    public func transform() throws -> Floating? {
        value
    }
    
    public static func transform(from value: Floating) throws -> String {
        // For some reason the switch with nan doesn't work 🤷‍♂️ as of Swift 5.2
        switch value {
        case _ where value.isNaN:
            return ValueProvider.nan
        case .infinity:
            return ValueProvider.positiveInfinity
        case -.infinity:
            return ValueProvider.negativeInfinity
        default:
            return String(describing: value)
        }
    }
}

extension NonConformingValue: DefaultValueProvider {
    
    public typealias DefaultType = Floating
    
    public static var hasDefaultValue: Floating {
        .zero
    }
}
