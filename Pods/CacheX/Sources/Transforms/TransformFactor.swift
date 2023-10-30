//
//  TransformFactor.swift
//  CacheX
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public protocol Transformeable {
    
}

public protocol TransformFactor {
    associatedtype Object
    
    func decode(_ data: Data?) -> Object?
    
    func encode(_ value: Object?) -> Data?
}
