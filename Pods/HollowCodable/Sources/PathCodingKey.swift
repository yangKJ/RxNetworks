//
//  AnyKey.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct PathCodingKey: CodingKey {
    
    public var stringValue: String
    public var intValue: Int?
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }
    
    public init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
    
    public static func string(_ string: String) -> PathCodingKey {
        PathCodingKey(stringValue: string)
    }
    
    public static func index(_ index: Int) -> PathCodingKey {
        PathCodingKey(intValue: index)
    }
}

extension PathCodingKey: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    
    public init(stringLiteral value: StaticString) {
        self.stringValue = value.description
        self.intValue = Int(stringValue)
    }
    
    public init(integerLiteral value: Int) {
        self.stringValue = String(describing: value)
        self.intValue = value
    }
}

extension PathCodingKey: Comparable, Hashable {
    public static func < (lhs: PathCodingKey, rhs: PathCodingKey) -> Bool {
        switch (lhs.intValue, rhs.intValue) {
        case (let lhs?, let rhs?):
            return lhs < rhs
        case (.some, nil):
            return true
        case (nil, .some):
            return false
        case (nil, nil):
            return lhs.stringValue < rhs.stringValue
        }
    }
}
