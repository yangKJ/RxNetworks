//
//  Typealias.swift
//  RxNetworks
//
//  Created by Condy on 2024/1/1.
//  https://github.com/yangKJ/RxNetworks

import Foundation
@_exported import Alamofire
@_exported import Moya

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

public typealias APIHost = String
public typealias APIPath = String
public typealias APINumber = Int
public typealias APIMethod = Moya.Method
public typealias APIParameters = Alamofire.Parameters
public typealias APIPlugins = [PluginSubType]
public typealias APIStubBehavior = Moya.StubBehavior

public typealias APIResultValue = Any
public typealias APIFailureError = MoyaError
public typealias APIResponseResult = Result<Moya.Response, APIFailureError>
public typealias APIJSONResult = Result<APIResultValue, APIFailureError>

public typealias APISuccessed = (_ response: Moya.Response) -> Void
public typealias APIFailure = (_ error: APIFailureError) -> Void
