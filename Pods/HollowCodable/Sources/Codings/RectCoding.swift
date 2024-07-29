//
//  CGRectCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/10.
//

import Foundation

/// `@CGRectCoding`: For a `CGRect` property that should be serialized to a x,y,width,height encoded dict.
public struct RectValue {
    
    var x: CGFloat?
    var y: CGFloat?
    var width: CGFloat?
    var height: CGFloat?
    
    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }
}

extension RectValue: Transformer {
    
    public typealias DecodeType = CGRect
    public typealias EncodeType = RectValue
    
    public init?(value: Any) { }
    
    public func transform() throws -> CGRect? {
        CGRect(x: x ?? 0, y: y ?? 0, width: width ?? 0, height: height ?? 0)
    }
    
    public static func transform(from value: CGRect) throws -> RectValue {
        RectValue.init(rect: value)
    }
}

extension RectValue: DefaultValueProvider {
    
    public typealias DefaultType = CGRect
    
    public static var hasDefaultValue: DefaultType {
        .zero
    }
}
