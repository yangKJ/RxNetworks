//
//  Typealias.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias BOOMINGView  = UIView
public typealias BOOMINGColor = UIColor
public typealias BOOMINGImage = UIImage
public typealias BOOMINGViewController = UIViewController
public typealias BOOMINGWindow = UIWindow
#elseif os(macOS)
import AppKit
public typealias BOOMINGView  = NSView
public typealias BOOMINGColor = NSColor
public typealias BOOMINGImage = NSImage
public typealias BOOMINGViewController = NSViewController
public typealias BOOMINGWindow = NSWindow
#endif
