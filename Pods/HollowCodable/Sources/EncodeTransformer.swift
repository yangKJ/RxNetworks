//
//  EncodeTransformer.swift
//  CodableExample
//
//  Created by Condy on 2024/7/7.
//

import Foundation

public protocol EncodeTransformer: Encodable {
    
    associatedtype DecodeType
    
    associatedtype EncodeType: Encodable
    
    static var selfEncodingFromEncoder: Bool { get }
    
    static func transform(from value: DecodeType) throws -> EncodeType
    
    static func transform(from value: DecodeType, to encoder: Encoder) throws
}

extension EncodeTransformer {
    
    public static var selfEncodingFromEncoder: Bool {
        false
    }
    
    public static func transform(from value: DecodeType, to encoder: Encoder) throws {
        
    }
}

extension EncodeTransformer where DecodeType == EncodeType {
    public static func transform(from value: DecodeType) throws -> EncodeType {
        value
    }
}
