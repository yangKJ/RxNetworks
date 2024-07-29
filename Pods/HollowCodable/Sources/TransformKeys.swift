//
//  StrategyKeys.swift
//  CodableExample
//
//  Created by Condy on 2024/7/3.
//

import Foundation

public struct TransformKeys: CodingKeyMapping {
    
    /// You need to replace it with a new coding key.
    public var keyString: String
    
    public let tranformer: any TransformType
    
    public init(key: String, tranformer: any TransformType) {
        self.keyString = key
        self.tranformer = tranformer
    }
    
    public init(location: CodingKey, tranformer: any TransformType) {
        self.keyString = location.stringValue
        self.tranformer = tranformer
    }
}

extension TransformKeys {
    
    func decodingStrategyDate(with decoder: any Decoder) -> Date? {
        guard let container = try? decoder.singleValueContainer(), !container.decodeNil() else {
            return nil
        }
        if let value = try? container.decode(String.self) {
            return tranformer.transformFromJSON(value) as? Date
        }
        if let value = try? container.decode(TimeInterval.self) {
            return tranformer.transformFromJSON(value) as? Date
        }
        if let value = try? container.decode(Int.self) {
            return tranformer.transformFromJSON(value) as? Date
        }
        if let value = try? container.decode(Date.self) {
            return tranformer.transformFromJSON(value) as? Date
        }
        return nil
    }
    
    func decodingStrategyData(with decoder: any Decoder) -> Data? {
        guard let container = try? decoder.singleValueContainer(), !container.decodeNil() else {
            return nil
        }
        if let value = try? container.decode(String.self) {
            return tranformer.transformFromJSON(value) as? Data
        }
        if let value = try? container.decode(Data.self) {
            return tranformer.transformFromJSON(value) as? Data
        }
        return nil
    }
    
    func encodingStrategy(with encoder: any Encoder, value: Any) throws {
        var container = encoder.singleValueContainer()
        if let value = tranform(decodedValue: value, transformer: tranformer) as? Encodable {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
    
    private func tranform<Transform: TransformType>(decodedValue: Any, transformer: Transform) -> Any? {
        if let value = decodedValue as? Transform.Object {
            return transformer.transformToJSON(value)
        }
        return nil
    }
}
