//
//  Hollow.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

/// 值得一提，这个库也挺不错的，采用宏的方式来实现，感兴趣可以去看看；
/// See: https://github.com/SwiftyLab/MetaCodable

import Foundation

/// Contract for providing a default value of a Type.
public protocol HollowValueProvider {
    associatedtype Value
    static var hasValue: Value { get }
}

public struct Hollow {
    public struct HasBoolean {
        /// Used types to pass values, equivalent to true.
        public enum yes: HollowValueProvider { 
            public static let hasValue: Bool = true
        }
        /// Used types to pass values, equivalent to false.
        public enum no: HollowValueProvider { 
            public static let hasValue: Bool = false
        }
        /// Used types to pass values, equivalent to nil.
        public enum nothing: HollowValueProvider {
            public typealias Value = Bool?
            public static let hasValue: Bool? = nil
        }
    }
    
    public struct EmptyString: HollowValueProvider {
        public static var hasValue: String { "" }
    }
    
    public struct ZeroInt: HollowValueProvider {
        public static var hasValue: Int { 0 }
    }
}

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
