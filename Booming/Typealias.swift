//
//  Typealias.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//

import Foundation

#if os(macOS)
import AppKit
public typealias ImageType = NSImage
public typealias ColorType = NSColor
public typealias ViewType = NSView
public typealias ImageViewType = NSImageView
public typealias LabelType = NSTextField
public typealias ViewControllerType = NSViewController
public typealias WindowType = NSWindow
#else
import UIKit
public typealias ImageType = UIImage
public typealias ColorType = UIColor
#if !os(watchOS)
public typealias ViewType = UIView
public typealias ImageViewType = UIImageView
public typealias LabelType = UILabel
public typealias ViewControllerType = UIViewController
public typealias WindowType = UIWindow
#if canImport(TVUIKit)
import TVUIKit
#endif
#if canImport(CarPlay) && !targetEnvironment(macCatalyst)
import CarPlay
#endif
#else
import WatchKit
#endif
#endif
