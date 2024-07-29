//
//  BoolCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

public typealias BoolFalse = BooleanValue<False>
public typealias BoolTrue = BooleanValue<True>

public protocol BooleanTogglable {
    static var value: Bool { get }
}

public enum False: BooleanTogglable {
    public static let value: Bool = false
}

public enum True: BooleanTogglable {
    public static let value: Bool = true
}

/// String or Int -> Bool converter.
/// Uses <= 0 as false, and > 0 as true.
/// Uses lowercase "true"/"yes"/"y"/"t"/"1"/">0" and "false"/"no"/"f"/"n"/"0".
/// `@BoolCoding` decodes int/string/bool value json into `Bool`.
public struct BooleanValue<HasDefault: BooleanTogglable>: Transformer {
    
    let boolean: Bool
    
    public typealias DecodeType = Bool
    public typealias EncodeType = Bool
    
    public init?(value: Any) {
        if let val = value as? Bool {
            self.boolean = val
            return
        } else if let val = value as? Int {
            self.boolean = val > 0 ? true : false
            return
        } else if let val = value as? Float {
            self.boolean = val > 0 ? true : false
            return
        }
        guard let string = Hollow.transfer2String(with: value), !string.hc.isEmpty2 else {
            return nil
        }
        let value = string.lowercased()
        switch value {
        case "1", "y", "t", "yes", "true":
            self.boolean = true
        case "0", "n", "f", "no", "false":
            self.boolean = false
        default:
            guard let val = Double(value) else {
                return nil
            }
            self.boolean = val > 0 ? true : false
        }
    }
    
    public func transform() throws -> Bool? {
        boolean
    }
}

extension BooleanValue: DefaultValueProvider {
    
    public typealias DefaultType = Bool
    
    public static var hasDefaultValue: DefaultType {
        HasDefault.value
    }
}
