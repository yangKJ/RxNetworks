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

public typealias HexColor_ = HexColor<False>

/// Support the hex string color with format `#RGB`、`#RGBA`、`#RRGGBB`、`#RRGGBBAA`
/// `@HexColorCoding`: For a Color property that should be serialized to a hex encoded String.
public struct HexColor<HasAlpha: BooleanTogglable>: Transformer {
    
    var hex: String?
    var hexInt: Int?
    
    public typealias DecodeType = HollowColor
    public typealias EncodeType = String
    
    public init?(value: Any) {
        switch value {
        case let string as String where !string.hc.isEmpty2:
            self.hex = string
        case let val as Int where (0x000000 ... 0xFFFFFF) ~= val:
            self.hexInt = val
        default:
            return nil
        }
    }
    
    public func transform() throws -> HollowColor? {
        if let hex = hex {
            return hexStringColor(with: hex)
        }
        if let hex = hexInt {
            return hexIntColor(with: hex)
        }
        return nil
    }
    
    public static func transform(from value: HollowColor) throws -> String {
        let comps = value.cgColor.components!
        let r = Int((comps[safe: 0] ?? 1.0) * 255.0)
        let g = Int((comps[safe: 1] ?? 1.0) * 255.0)
        let b = Int((comps[safe: 2] ?? 1.0) * 255.0)
        //let rgb = ((r) << 16) | (Int(g) << 8) | Int(b)
        //hexString += String(format: "%06X", rgb)
        var hexString: String = "#"
        hexString += String(format: "%02X%02X%02X", r, g, b)
        if HasAlpha.value {
            let a = Int((comps[safe: 3] ?? 1.0) * 255.0)
            hexString += String(format: "%02X", a)
        }
        return hexString
    }
    
    private func hexStringColor(with hex: String) -> HollowColor? {
        var input = hex.replacingOccurrences(of: "#", with: "").uppercased()
        if input.hasPrefix("0X") {
            input = String(input.dropFirst(2))
        }
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
    
    private func hexIntColor(with hex: Int) -> HollowColor? {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat((hex) & 0xFF) / 255.0
        return HollowColor.init(red: r, green: g, blue: b, alpha: 1)
    }
}

extension HexColor: DefaultValueProvider {
    
    public static var hasDefaultValue: HollowColor {
        .clear
    }
}
