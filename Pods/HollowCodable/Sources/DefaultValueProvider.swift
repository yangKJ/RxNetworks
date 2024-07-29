//
//  DefaultValueProvider.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

public typealias HasDefaultValuable = DefaultValueProvider

/// Provides a default value for missing `Decodable` data.
/// The `@DefaultBacked` property wrapper takes a DefaultValueProvider as a parameter.
/// This type provides the default value when a value is not present or is nil.
public protocol DefaultValueProvider {
    
    associatedtype DefaultType
    
    /// The fallback value used when decoding fails.
    static var hasDefaultValue: DefaultType { get }
}

extension DefaultValueProvider where Self: FixedWidthInteger {
    public static var hasDefaultValue: Self {
        return .zero
    }
}

extension DefaultValueProvider where Self: BinaryFloatingPoint {
    public static var hasDefaultValue: Self {
        return .zero
    }
}

extension Int: DefaultValueProvider { }
extension Int8: DefaultValueProvider { }
extension Int16: DefaultValueProvider { }
extension Int32: DefaultValueProvider { }
extension Int64: DefaultValueProvider { }
extension UInt: DefaultValueProvider { }
extension UInt8: DefaultValueProvider { }
extension UInt16: DefaultValueProvider { }
extension UInt32: DefaultValueProvider { }
extension UInt64: DefaultValueProvider { }
extension Float: DefaultValueProvider { }
extension Double: DefaultValueProvider { }
extension CGFloat: DefaultValueProvider { }

extension String: DefaultValueProvider {
    public static let hasDefaultValue: String = ""
}

extension Bool: DefaultValueProvider {
    public static let hasDefaultValue: Bool = false
}

extension Decimal: DefaultValueProvider {
    public static let hasDefaultValue: Decimal = .zero
}

extension Data: DefaultValueProvider {
    public static let hasDefaultValue: Data = Data()
}

extension Date: DefaultValueProvider {
    public static let hasDefaultValue: Date = Date(timeIntervalSinceReferenceDate: 0)
}

extension Set: DefaultValueProvider where Set.Element: Codable {
    public static var hasDefaultValue: Set<Element> {
        return Set<Element>()
    }
}

extension Array: DefaultValueProvider where Array.Element: Codable {
    public static var hasDefaultValue: Array<Element> {
        return Array<Element>()
    }
}

extension Dictionary: DefaultValueProvider where Dictionary.Key: Hashable, Dictionary.Value: Codable {
    public static var hasDefaultValue: Dictionary<Key, Value> {
        return Dictionary<Key, Value>()
    }
}

extension Optional: DefaultValueProvider where Wrapped: Codable {
    public static var hasDefaultValue: Optional<Wrapped> {
        return Optional<Any>.none as? Wrapped
    }
}
