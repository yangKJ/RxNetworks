//
//  NetworkAPI.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

///`Moya`文档
/// https://github.com/Moya/Moya
///
///`Alamofire`文档
/// https://github.com/Alamofire/Alamofire
///

import Moya

public protocol NetworkAPI: Moya.TargetType {
    
    /// Request host
    var ip: APIHost { get }
    /// Request parameters
    var parameters: APIParameters? { get }
    /// Plugin array
    var plugins: APIPlugins { get }
    /// Whether to go test data
    var stubBehavior: APIStubBehavior { get }
    /// Failed retry count, the default is zero
    var retry: APINumber { get }
    
    /// Identification key prefix, defaul MD5 request link.
    var keyPrefix: String { get }
    
    /// Default true.
    var httpShouldHandleCookies: Bool { get }
    
    /// A responsible for returning an `EndpointSampleResponse`.
    var sampleResponse: Moya.EndpointSampleResponse { get }
    
    /// Mapped to json, Default is true.
    var mapped2JSON: Bool { get }
    
    /// Remove all HUDs displayed to `LevelStatusBarWindowController`.
    func removeHUD()
    
    /// Remove  displaying in the window`BoomingSetup.loadingPluginNames` loading.
    func removeLoading()
}
