//
//  ImmutableWrapper.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

/// Made immutable via property wrapper composition, It can be used with other encoding/decoding.
/// Like this: `@Immutable @BoolCoding var bar: Bool?`
@propertyWrapper public struct Immutable<T>: ImmutableGetWrapper {
    
    public let wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension Immutable: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Immutable: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try T(from: decoder))
    }
}

extension Immutable where T: Codable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try T(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Immutable: Equatable where T: Equatable { }
extension Immutable: Hashable where T: Hashable { }

public protocol ImmutableGetWrapper {
    associatedtype T
    var wrappedValue: T { get }
    init(wrappedValue: T)
}
