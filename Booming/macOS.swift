//
//  macOS.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//  https://github.com/yangKJ/RxNetworks

import Foundation

#if canImport(AppKit)
import AppKit

extension NSImage {
    var cgImage: CGImage? {
        var rect = NSRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
    
    func pngData() -> Data? {
        guard let representation = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: representation) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
    
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let representation = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: representation) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    
    func heicData() -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
              let cgImage = cgImage else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return mutableData as Data
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

#endif
