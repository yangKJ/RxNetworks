//
//  RGBColor.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

/// `@RGBColorCoding`: Decoding a red,green,blue to color.
public struct RGB {
    
    var red: CGFloat?
    var green: CGFloat?
    var blue: CGFloat?
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

extension RGB: Transformer {
    
    public typealias DecodeType = HollowColor
    public typealias EncodeType = RGB
    
    public init?(value: Any) { }
    
    public func transform() throws -> HollowColor? {
        let r = (red ?? 255.0) / 255.0
        let g = (green ?? 255.0) / 255.0
        let b = (blue ?? 255.0) / 255.0
        return DecodeType.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    public static func transform(from value: HollowColor) throws -> RGB {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        value.getRed(&r, green: &g, blue: &b, alpha: nil)
        r *= 255.0
        g *= 255.0
        b *= 255.0
        return RGB.init(red: r, green: g, blue: b)
    }
}

extension RGB: DefaultValueProvider {
    
    public static var hasDefaultValue: HollowColor {
        .clear
    }
}
