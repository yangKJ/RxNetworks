//
//  HexColorCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation
#if canImport(UIKit)
import UIKit
public typealias HollowColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias HollowColor = NSColor
#endif

@propertyWrapper public struct HexColorHasCoding<T: HollowValueProvider>: Codable {
    
    public let wrappedValue: HollowColor?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try HexColorDecoding(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try HexColorHasEncoding<T>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct HexColorDecoding: Decodable {
    
    public let wrappedValue: HollowColor?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        self.wrappedValue = HexColorDecoding.color(with: hex)
    }
    
    static func color(with hex: String) -> HollowColor? {
        let input = hex.replacingOccurrences(of: "#", with: "").uppercased()
        var a: CGFloat = 1.0, r: CGFloat = 0.0, b: CGFloat = 0.0, g: CGFloat = 0.0
        func colorComponent(from string: String, start: Int, length: Int) -> CGFloat {
            let substring = (string as NSString).substring(with: NSRange(location: start, length: length))
            let fullHex = length == 2 ? substring : "\(substring)\(substring)"
            var hexComponent: UInt64 = 0
            Scanner(string: fullHex).scanHexInt64(&hexComponent)
            return CGFloat(Double(hexComponent) / 255.0)
        }
        switch (input.count) {
        case 3 /* #RGB */:
            r = colorComponent(from: input, start: 0, length: 1)
            g = colorComponent(from: input, start: 1, length: 1)
            b = colorComponent(from: input, start: 2, length: 1)
        case 4 /* #RGBA */:
            r = colorComponent(from: input, start: 0, length: 1)
            g = colorComponent(from: input, start: 1, length: 1)
            b = colorComponent(from: input, start: 2, length: 1)
            a = colorComponent(from: input, start: 3, length: 1)
        case 6 /* #RRGGBB */:
            r = colorComponent(from: input, start: 0, length: 2)
            g = colorComponent(from: input, start: 2, length: 2)
            b = colorComponent(from: input, start: 4, length: 2)
        case 8 /* #RRGGBBAA */:
            r = colorComponent(from: input, start: 0, length: 2)
            g = colorComponent(from: input, start: 2, length: 2)
            b = colorComponent(from: input, start: 4, length: 2)
            a = colorComponent(from: input, start: 6, length: 2)
        default:
            return nil
        }
        return HollowColor.init(red: r, green: g, blue: b, alpha: a)
    }
}

@propertyWrapper public struct HexColorHasEncoding<T: HollowValueProvider>: Encodable {
    
    public let wrappedValue: HollowColor?
    
    public init(_ wrappedValue: HollowColor?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let color = self.wrappedValue {
            try container.encode(HexColorHasEncoding.hexString(color: color))
        } else {
            try container.encodeNil()
        }
    }
    
    static func hexString(color: HollowColor) -> String {
        let comps = color.cgColor.components!
        let r = Int(comps[0] * 255)
        let g = Int(comps[1] * 255)
        let b = Int(comps[2] * 255)
        let a = Int(comps[3] * 255)
        var hexString: String = "#"
        hexString += String(format: "%02X%02X%02X", r, g, b)
        if let val = T.hasValue as? Bool, val {
            hexString += String(format: "%02X", a)
        }
        return hexString
    }
}
