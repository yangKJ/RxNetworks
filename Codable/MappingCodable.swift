//
//  MappingCodable.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public typealias ReplaceKeys = [(newKey: String, oldKey: String)]

public protocol MappingCodable: Codable {
    static var codingKeys: ReplaceKeys { get }
}

extension MappingCodable {
    public static var codingKeys: ReplaceKeys { [] }
}
