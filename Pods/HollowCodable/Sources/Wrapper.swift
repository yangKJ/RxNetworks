//
//  Wrapper.swift
//  CodableExample
//
//  Created by Condy on 2024/7/5.
//

import Foundation

public struct HollowWrapper<Base> {
    public let base: Base
}

public protocol HollowCompatible { }

extension HollowCompatible {
    
    public var hc: HollowWrapper<Self> {
        get { return HollowWrapper(base: self) }
        set { }
    }
    
    public static var hc: HollowWrapper<Self>.Type {
        HollowWrapper<Self>.self
    }
}

extension String: HollowCompatible { }
extension Double: HollowCompatible { }
extension NSDecimalNumber: HollowCompatible { }
extension Data: HollowCompatible { }
