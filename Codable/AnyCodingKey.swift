//
//  AnyKey.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct AnyCodingKey: CodingKey, Hashable {
    public var stringValue: String
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int?
    
    public init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
