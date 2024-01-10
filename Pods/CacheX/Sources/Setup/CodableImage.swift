//
//  CodableImage.swift
//  CacheX
//
//  Created by Condy on 2023/3/30.
//

import Foundation
#if canImport(UIKit)
import UIKit
public typealias CacheXImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias CacheXImage = NSImage
#endif

@propertyWrapper public struct CodableImage_: Codable {
    
    var image: CacheXImage?
    
    public enum CodingKeys: String, CodingKey {
        case date
        case scale
    }
    
    public init(image: CacheXImage?) {
        self.image = image
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scale = try container.decode(CGFloat.self, forKey: CodingKeys.scale)
        let data = try container.decode(Data.self, forKey: CodingKeys.date)
        self.image = CacheXImage(data: data, scale: scale)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = image, let data = image.pngData() {
            try container.encode(data, forKey: CodingKeys.date)
            try container.encode(image.scale, forKey: CodingKeys.scale)
        } else {
            try container.encodeNil(forKey: CodingKeys.date)
            try container.encodeNil(forKey: CodingKeys.scale)
        }
    }
    
    public init(wrappedValue: CacheXImage?) {
        self.init(image: wrappedValue)
    }
    
    public var wrappedValue: CacheXImage? {
        get { image }
        set { image = newValue }
    }
}

#if canImport(AppKit)
import AppKit

extension NSImage {
    
    convenience init?(data: Data, scale: CGFloat) {
        self.init(data: data)
    }
    
    var scale: CGFloat {
        guard let pixelsWide = representations.first?.pixelsWide else {
            return 1.0
        }
        let scale: CGFloat = CGFloat(pixelsWide) / size.width
        return scale
    }
    
    func pngData() -> Data? {
        guard let rep = tiffRepresentation, let bitmap = NSBitmapImageRep(data: rep) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}
#endif
