//
//  EnumCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public protocol CaseDefaultProvider: RawRepresentable {
    static var defaultCase: Self { get }
}

extension CaseDefaultProvider where Self: CaseIterable {
    public static var defaultCase: Self {
        Self.allCases.first!
    }
}

/// Enumeration series,
/// `@EnumCoding`: To be convertable, An enum must conform to RawRepresentable protocol.
public struct EnumValue<T: RawRepresentable>: Transformer where T.RawValue: Codable {
    
    let value: T.RawValue
    
    public typealias DecodeType = T
    public typealias EncodeType = T.RawValue
    
    public init?(value: Any) {
        guard let value = value as? T.RawValue else {
            return nil
        }
        self.value = value
    }
    
    public func transform() throws -> T? {
        T.init(rawValue: value)
    }
    
    public static func transform(from value: T) throws -> T.RawValue {
        value.rawValue
    }
}

extension EnumValue: DefaultValueProvider where T: CaseDefaultProvider {
    
    public typealias DefaultType = T
    
    public static var hasDefaultValue: DefaultType {
        T.defaultCase
    }
}
