//
//  RGBAColorCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/10.
//

import Foundation

/// `@RGBAColorCoding`: Decoding a red,green,blue,alpha to color.
public struct RGBA {
    
    var red: CGFloat?
    var green: CGFloat?
    var blue: CGFloat?
    var alpha: CGFloat?
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension RGBA: Transformer {
    
    public typealias DecodeType = HollowColor
    public typealias EncodeType = RGBA
    
    public init?(value: Any) { }
    
    public func transform() throws -> HollowColor? {
        let r = (red ?? 255.0) / 255.0
        let g = (green ?? 255.0) / 255.0
        let b = (blue ?? 255.0) / 255.0
        let a = (alpha ?? 255.0) / 255.0
        return DecodeType.init(red: r, green: g, blue: b, alpha: a)
    }
    
    public static func transform(from value: HollowColor) throws -> RGBA {
        let comps = value.cgColor.components!
        let r = ((comps[safe: 0] ?? 1.0) * 255.0)
        let g = ((comps[safe: 1] ?? 1.0) * 255.0)
        let b = ((comps[safe: 2] ?? 1.0) * 255.0)
        let a = ((comps[safe: 3] ?? 1.0) * 255.0)
        return RGBA.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension RGBA: DefaultValueProvider {
    
    public static var hasDefaultValue: HollowColor {
        .clear
    }
}
