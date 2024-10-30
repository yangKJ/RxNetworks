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
    
    /// Default cache policy for requests. Default is `BoomingSetup.requestCachePolicy` value.
    var requestCachePolicy: NSURLRequest.CachePolicy { get }
    
    /// This will cause a timeout if no data is transmitted for the given timeout value.
    /// Default is `BoomingSetup.timeoutIntervalForRequest` value.
    var timeoutIntervalForRequest: Double { get }
    
    /// Allow the session to set cookies on requests. Default is `BoomingSetup.HTTPShouldSetCookies` value.
    var httpShouldHandleCookies: Bool { get }
    
    /// Allow the use of HTTP pipelining. Default is `BoomingSetup.HTTPShouldUsePipelining` value.
    var httpShouldUsePipelining: Bool { get }
    
    /// Mapped to json, Default is `BoomingSetup.mapped2JSON` value.
    var mapped2JSON: Bool { get }
    
    /// A responsible for returning an `EndpointSampleResponse`.
    var sampleResponse: Moya.EndpointSampleResponse { get }
    
    /// Remove all HUDs displayed to `LevelStatusBarWindowController`.
    func removeHUD()
    
    /// Remove  displaying in the window`BoomingSetup.loadingPluginNames` loading.
    func removeLoading()
}
