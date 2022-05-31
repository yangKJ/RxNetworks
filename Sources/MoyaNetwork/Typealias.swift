//
//  Typealias.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/30.
//  https://github.com/yangKJ/RxNetworks

///`Moya`文档
/// https://github.com/Moya/Moya
///
///`Alamofire`文档
/// https://github.com/Alamofire/Alamofire

import Foundation
@_exported import Alamofire
@_exported import Moya

public typealias APIHost = String
public typealias APIPath = String
public typealias APINumber = Int
public typealias APIMethod = Moya.Method
public typealias APIParameters = Alamofire.Parameters
public typealias APIPlugins = [RxNetworks.PluginSubType]
public typealias APIStubBehavior = Moya.StubBehavior

public typealias APISuccess = (_ json: Any) -> Void
public typealias APIFailure = (_ error: Swift.Error) -> Void
