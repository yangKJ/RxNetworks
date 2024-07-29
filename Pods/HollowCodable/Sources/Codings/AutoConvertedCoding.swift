//
//  AutoConvertedCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/10.
//

import Foundation

public typealias BackedCoding<T: Codable & CustomStringConvertible> = AnyBacked<AutoConvertedValue<T>>

/// Decodes automatic type conversion.
/// `@AutoConvertCoding` decodes String and filters invalid values if the Decoder is unable to decode the value.
/// Automatic change of type, like int <-> string, bool <-> string.
public struct AutoConvertedValue<T: CustomStringConvertible>: Transformer where T: Codable {
    
    let value: T
    
    public typealias DecodeType = T
    public typealias EncodeType = T
    
    public static var selfDecodingFromDecoder: Bool {
        true
    }
    
    public init?(value: Any) {
        guard let decoder = value as? Decoder else {
            return nil
        }
        if let value = try? T.init(from: decoder) {
            self.value = value
            return
        }
        guard let value = Self.decodeValue(with: decoder) else {
            return nil
        }
        self.value = value
    }
    
    public func transform() throws -> T? {
        value
    }
}

extension AutoConvertedValue: DefaultValueProvider {
    public static var hasDefaultValue: T {
        switch T.self {
        case is any FloatingPoint.Type:
            return 0.0 as! T
        case is any FixedWidthInteger.Type:
            return 0 as! T
        case is any Numeric.Type:
            return 0 as! T
        case is Bool.Type:
            return Bool.hasDefaultValue as! T
        case is String.Type:
            return String.hasDefaultValue as! T
        case is Decimal.Type:
            return Decimal.hasDefaultValue as! T
        case is Date.Type:
            return Date.hasDefaultValue as! T
        case is Data.Type:
            return Data.hasDefaultValue as! T
        default:
            return Optional<Any>.none as! T
        }
    }
}

extension AutoConvertedValue {
    
    static func decodeValue(with decoder: Decoder) -> T? {
        guard let container = try? decoder.singleValueContainer() else {
            return nil
        }
        if let val = try? container.decode(T.self) {
            return val
        } else if T.self == String.self {
            return decodeStringValue(with: container)
        } else if T.self == Bool.self {
            return decodeBoolValue(with: container)
        } else if T.self == CGFloat.self {
            return decodeCGFloatValue(with: container)
        } else if T.self == Float.self {
            return decodeValue(with: container, type: Float.self)
        } else if T.self == Double.self {
            return decodeValue(with: container, type: Double.self)
        } else if T.self == Int.self {
            return decodeValue(with: container, type: Int.self)
        } else if T.self == Int8.self {
            return decodeValue(with: container, type: Int8.self)
        } else if T.self == Int16.self {
            return decodeValue(with: container, type: Int16.self)
        } else if T.self == Int32.self {
            return decodeValue(with: container, type: Int32.self)
        } else if T.self == Int64.self {
            return decodeValue(with: container, type: Int64.self)
        } else if T.self == UInt.self {
            return decodeValue(with: container, type: UInt.self)
        } else if T.self == UInt8.self {
            return decodeValue(with: container, type: UInt8.self)
        } else if T.self == UInt16.self {
            return decodeValue(with: container, type: UInt16.self)
        } else if T.self == UInt32.self {
            return decodeValue(with: container, type: UInt32.self)
        } else if T.self == UInt64.self {
            return decodeValue(with: container, type: UInt64.self)
        }
        return nil
    }
    
    static func decodeBoolValue(with container: SingleValueDecodingContainer) -> T? {
        if let value = try? container.decode(String.self) {
            return BooleanValue<False>.init(value: value)?.boolean as? T
        } else if let value = try? container.decode(Int.self) {
            return BooleanValue<False>.init(value: value)?.boolean as? T
        } else if let value = try? container.decode(UInt.self) {
            return BooleanValue<False>.init(value: value)?.boolean as? T
        } else if let value = try? container.decode(Float.self) {
            return BooleanValue<False>.init(value: value)?.boolean as? T
        } else if let value = try? container.decode(Double.self) {
            return BooleanValue<False>.init(value: value)?.boolean as? T
        }
        return nil
    }
    
    static func decodeStringValue(with container: SingleValueDecodingContainer) -> T? {
        if let value = try? container.decode(Int.self) {
            return value.description as? T
        } else if let value = try? container.decode(UInt.self) {
            return value.description as? T
        } else if let value = try? container.decode(Float.self) {
            return value.description as? T
        } else if let value = try? container.decode(Double.self) {
            return value.description as? T
        } else if let value = try? container.decode(Bool.self) {
            return value.description as? T
        }
        return nil
    }
    
    static func decodeCGFloatValue(with container: SingleValueDecodingContainer) -> T? {
        if let value = try? container.decode(String.self) {
            if let num = NumberFormatter().number(from: value) {
                return CGFloat(truncating: num) as? T
            }
        } else if let value = try? container.decode(Int.self) {
            return CGFloat(value) as? T
        } else if let value = try? container.decode(UInt.self) {
            return CGFloat(value) as? T
        } else if let value = try? container.decode(Float.self) {
            return CGFloat(value) as? T
        } else if let value = try? container.decode(Double.self) {
            return CGFloat(value) as? T
        } else if let value = try? container.decode(Bool.self) {
            return (value ? 1.0 : 0.0) as? T
        }
        return nil
    }
    
    static func decodeValue<TT>(with container: SingleValueDecodingContainer, type: TT.Type) -> T? where TT: FixedWidthInteger & LosslessStringConvertible {
        if let value = try? container.decode(Int64.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(String.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(UInt64.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(Double.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(Bool.self) {
            return TT(value ? 1 : 0) as? T
        }
        return nil
    }
    
    static func decodeValue<TT>(with container: SingleValueDecodingContainer, type: TT.Type) -> T? where TT: BinaryFloatingPoint & LosslessStringConvertible {
        if let value = try? container.decode(Int64.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(String.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(UInt64.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(Double.self) {
            return TT(value) as? T
        } else if let value = try? container.decode(Bool.self) {
            return TT(value ? 1 : 0) as? T
        }
        return nil
    }
}
