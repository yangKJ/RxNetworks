//
//  Extension+macOS.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//  https://github.com/yangKJ/RxNetworks

import Foundation

#if canImport(AppKit)
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

extension NSWindow {
    var rootViewController: NSViewController? {
        get {
            return contentViewController
        }
        set {
            self.contentViewController = newValue
        }
    }
    
    var isHidden: Bool {
        get {
            return canHide
        }
        set {
            self.canHide = newValue
        }
    }
}

extension NSView {
    var center: CGPoint {
        get {
            return CGPointMake(NSMidX(frame), NSMidY(frame))
        }
    }
    
    var backgroundColor: NSColor? {
        get {
            guard let cg = self.layer?.backgroundColor else {
                return nil
            }
            return NSColor.init(cgColor: cg)
        }
        set {
            self.layer?.backgroundColor = newValue?.cgColor
            self.needsDisplay = true
            //self.layoutSubtreeIfNeeded()
        }
    }
}

extension NSTextField {
    var text: String? {
        get {
            return stringValue
        }
        set {
            stringValue = newValue ?? ""
        }
    }
}

#endif
