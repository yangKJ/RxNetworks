//
//  Transformer.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

public typealias Transformer = DecodeTransformer & EncodeTransformer

extension Int: Transformer {
    public typealias DecodeType = Int
    public typealias EncodeType = Int
}

extension Int8: Transformer {
    public typealias DecodeType = Int8
    public typealias EncodeType = Int8
}

extension Int16: Transformer {
    public typealias DecodeType = Int16
    public typealias EncodeType = Int16
}

extension Int32: Transformer {
    public typealias DecodeType = Int32
    public typealias EncodeType = Int32
}

extension Int64: Transformer {
    public typealias DecodeType = Int64
    public typealias EncodeType = Int64
}

extension UInt: Transformer {
    public typealias DecodeType = UInt
    public typealias EncodeType = UInt
}

extension UInt8: Transformer {
    public typealias DecodeType = UInt8
    public typealias EncodeType = UInt8
}

extension UInt16: Transformer {
    public typealias DecodeType = UInt16
    public typealias EncodeType = UInt16
}

extension UInt32: Transformer {
    public typealias DecodeType = UInt32
    public typealias EncodeType = UInt32
}

extension UInt64: Transformer {
    public typealias DecodeType = UInt64
    public typealias EncodeType = UInt64
}

extension Float: Transformer {
    public typealias DecodeType = Float
    public typealias EncodeType = Float
}

extension Double: Transformer {
    public typealias DecodeType = Double
    public typealias EncodeType = Double
}

extension String: Transformer {
    public typealias DecodeType = String
    public typealias EncodeType = String
}

extension CGFloat: Transformer {
    public typealias DecodeType = CGFloat
    public typealias EncodeType = CGFloat
    public init?(value: Any) {
        if let val = value as? DecodeType {
            self = val
        } else if let val = Hollow.transfer2String(with: value), let num = NumberFormatter().number(from: val) {
            self = CGFloat(truncating: num)
        } else {
            return nil
        }
    }
}

extension Bool: Transformer {
    public typealias DecodeType = Bool
    public typealias EncodeType = Bool
    public init?(value: Any) {
        guard let val = BooleanValue<False>.init(value: value) else {
            return nil
        }
        self = val.boolean
    }
}

extension Decimal: Transformer {
    public typealias DecodeType = Decimal
    public typealias EncodeType = Decimal
    public init?(value: Any) {
        if let val = value as? DecodeType {
            self = val
        } else if let val = Hollow.transfer2String(with: value), let decimal = Decimal(string: val) {
            self = decimal
        } else {
            return nil
        }
    }
}

extension URL: Transformer {
    public typealias DecodeType = URL
    public typealias EncodeType = URL
    public init?(value: Any) {
        if let val = value as? DecodeType {
            self = val
        } else if let val = value as? String, val.hc.isValidLink, let url = URL(string: val) {
            self = url
        } else {
            return nil
        }
    }
}

extension Array: Transformer where Array.Element: HollowCodable {
    public typealias DecodeType = Array
    public typealias EncodeType = Array
    public init?(value: Any) {
        if let array = value as? Array<Element> {
            self = array
            return
        }
        guard let array = [Element].deserialize(from: value) else {
            return nil
        }
        self = array
    }
}

extension Set: Transformer where Set.Element: HollowCodable {
    public typealias DecodeType = Set
    public typealias EncodeType = Set
    public init?(value: Any) {
        if let array = value as? [Element] {
            self = Set(array)
            return
        }
        guard let array = [Element].deserialize(from: value) else {
            return nil
        }
        self = Set(array)
    }
}

extension Dictionary: Transformer where Key: Codable, Value: HollowCodable {
    public typealias DecodeType = Dictionary
    public typealias EncodeType = Dictionary
    public init?(value: Any) {
        if let dict = value as? Dictionary<Key, Value> {
            self = dict
            return
        }
        guard let dict = [Key: Value].deserialize(from: value) else {
            return nil
        }
        self = dict
    }
}

extension Optional: Transformer where Wrapped: Codable {
    public typealias DecodeType = Optional
    public typealias EncodeType = Optional
    public init?(value: Any) {
        if let val = value as? DecodeType {
            self = val
        } else if let val = value as? Wrapped {
            self = Optional(val)
        } else if Wrapped.self == String.self, let val = Hollow.transfer2String(with: value) {
            self = Optional(val as! Wrapped)
        } else {
            return nil
        }
    }
}
