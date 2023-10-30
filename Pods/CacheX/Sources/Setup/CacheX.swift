//
//  CacheX.swift
//  CacheX
//
//  Created by Condy on 2023/3/30.
//

import Foundation

public struct CacheXWrapper<Base> {
    public let base: Base
}

public protocol CacheXCompatible { }

extension CacheXCompatible {
    
    public var cx: CacheXWrapper<Self> {
        get { return CacheXWrapper(base: self) }
        set { }
    }
    
    public static var cx: CacheXWrapper<Self>.Type {
        CacheXWrapper<Self>.self
    }
}

extension Data: CacheXCompatible { }
extension String: CacheXCompatible { }
