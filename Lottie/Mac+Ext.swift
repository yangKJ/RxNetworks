//
//  Mac+Ext.swift
//  NetworkLottiePlugin
//
//  Created by Condy on 2024/6/6.
//

import Foundation

#if canImport(AppKit)
import AppKit

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
