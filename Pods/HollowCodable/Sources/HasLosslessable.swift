//
//  HasLosslessDecodingTypes.swift
//  CodableExample
//
//  Created by Condy on 2024/7/20.
//

import Foundation

public protocol HasLosslessable {
    /// An ordered list of decodable scenarios used to infer the encoded type
    static func losslessDecodableTypes(with decoder: Decoder) -> [Decodable?]
}

public struct DefaultLosslessDecodingTypes: HasLosslessable {
    public static func losslessDecodableTypes(with decoder: Decoder) -> [Decodable?] {
        return [
            try? String.init(from: decoder),
            try? Bool.init(from: decoder),
            try? Int.init(from: decoder),
            try? Int8.init(from: decoder),
            try? Int16.init(from: decoder),
            try? Int32.init(from: decoder),
            try? Int64.init(from: decoder),
            try? UInt.init(from: decoder),
            try? UInt8.init(from: decoder),
            try? UInt16.init(from: decoder),
            try? UInt32.init(from: decoder),
            try? UInt64.init(from: decoder),
            try? Double.init(from: decoder),
            try? Float.init(from: decoder),
            try? CGFloat.init(from: decoder),
            try? UUID.init(from: decoder),
            try? URL.init(from: decoder),
            try? Data.init(from: decoder),
            try? Date.init(from: decoder),
            try? Decimal.init(from: decoder),
        ]
    }
}
