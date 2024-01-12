//
//  Extension+macOS.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//

import Foundation

#if os(macOS)
import AppKit

extension NSImage {
    func pngData() -> Data? {
        guard let representation = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: representation) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}

#endif
