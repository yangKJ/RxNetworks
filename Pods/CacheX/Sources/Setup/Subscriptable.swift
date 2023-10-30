//
//  Subscriptable.swift
//  CacheX
//
//  Created by Condy on 2023/5/20.
//

import Foundation

public protocol Subscriptable {
    
    associatedtype Key
    associatedtype Value
    
    subscript(_ key: Key) -> Value? { get set }
}
