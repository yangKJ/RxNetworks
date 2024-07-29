//
//  PointCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

/// `@PointCoding`: For a `CGPoint` property that should be serialized to a x,y encoded dict.
public struct PointValue {
    
    var x: CGFloat?
    var y: CGFloat?
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

extension PointValue: Transformer {
    
    public typealias DecodeType = CGPoint
    public typealias EncodeType = PointValue
    
    public init?(value: Any) { }
    
    public func transform() throws -> CGPoint? {
        .init(x: x ?? 0, y: y ?? 0)
    }
    
    public static func transform(from value: CGPoint) throws -> PointValue {
        PointValue.init(x: value.x, y: value.y)
    }
}

extension PointValue: DefaultValueProvider {
    
    public typealias DefaultType = CGPoint
    
    public static var hasDefaultValue: DefaultType {
        .zero
    }
}
