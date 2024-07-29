//
//  LosslessValueCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/10.
//

import Foundation

public typealias LosslessValue<T: LosslessStringConvertible & Codable> = LosslessHasValue<T, DefaultLosslessDecodingTypes>

/// Decodes Codable values into their respective preferred types.
/// `@LosslessCoding` attempts to decode Codable types into their preferred order
/// while preserving the data in the most lossless format.
public struct LosslessHasValue<T: LosslessStringConvertible, Has: HasLosslessable>: Transformer where T: Codable {
    
    let value: T
    
    public typealias DecodeType = T
    public typealias EncodeType = String
    
    public static var selfDecodingFromDecoder: Bool {
        true
    }
    
    public init?(value: Any) {
        guard let decoder = value as? Decoder else {
            return nil
        }
        guard let rawValue = Has.losslessDecodableTypes(with: decoder).lazy.compactMap({ $0 }).first else {
            return nil
        }
        if T.self == Bool.self, let val = rawValue as? Int {
            if let v = Bool(exactly: NSNumber(value: val)) {
                self.value = v as! T
                return
            }
        }
        if let val = rawValue as? String, let string = T.init(val) {
            self.value = string
            return
        }
        if let string = T.init("\(rawValue)") {
            self.value = string
            return
        }
        return nil
    }
    
    public func transform() throws -> T? {
        value
    }
    
    public static func transform(from value: T) throws -> String {
        value.description
    }
}

extension LosslessHasValue: DefaultValueProvider {
    
    public static var hasDefaultValue: T {
        switch T.self {
        case is any Numeric.Type:
            return T.init("0")!
        case is Bool.Type:
            return T.init(false.description)!
        case is String.Type:
            return T.init("")!
        case is Date.Type:
            return T.init(Date.hasDefaultValue.description)!
        case is Data.Type:
            return T.init(Data.hasDefaultValue.description)!
        default:
            return T.init("")!
        }
    }
}
