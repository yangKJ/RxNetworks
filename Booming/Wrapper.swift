//
//  Wrapper.swift
//  Booming
//
//  Created by Condy on 2024/6/13.
//

import Foundation

/// Add the `bpm` prefix namespace.
public struct BoomingWrapper<Base> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var base: Base
    /// Create an instance from the provided value.
    public init(base: Base) {
        self.base = base
    }
}

/// Protocol describing the `bpm` extension points for Alamofire extended types.
public protocol BoomingCompatible { }

extension BoomingCompatible {
    
    public var bpm: BoomingWrapper<Self> {
        get { return BoomingWrapper(base: self) }
        set { }
    }
    
    public static var bpm: BoomingWrapper<Self>.Type {
        BoomingWrapper<Self>.self
    }
}
