//
//  TransientCodable.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

public protocol TransientCodable: TransientEncodable, TransientDecodable where ValueType == InitType { }

public protocol TransientEncodable: Encodable {
    associatedtype ValueType: Encodable
    var wrappedValue: ValueType { get }
}

public extension TransientEncodable {
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

public protocol TransientDecodable: Decodable {
    associatedtype InitType: Decodable
    init(wrappedValue: InitType)
}

public extension TransientDecodable {
    init(from decoder: Decoder) throws {
        self.init(wrappedValue: try InitType(from: decoder))
    }
}
