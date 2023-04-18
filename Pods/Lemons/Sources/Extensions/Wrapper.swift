//
//  Wrapper.swift
//  Lemons
//
//  Created by Condy on 2023/4/4.
//

import Foundation

/// Add the `lem` prefix namespace
public struct Lemon<Base> {
    public let base: Base
}

public protocol LemonsWrapper { }

extension LemonsWrapper {
    
    /// Instance naming prefix.
    public var lem: Lemon<Self> {
        get { return Lemon(base: self) }
        set { }
    }
    
    public static var lem: Lemon<Self>.Type {
        Lemon<Self>.self
    }
}
