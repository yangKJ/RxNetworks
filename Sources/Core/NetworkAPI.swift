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

@_exported import Alamofire
@_exported import Moya

public typealias APIHost = String
public typealias APIPath = String
public typealias APINumber = Int
public typealias APIMethod = Moya.Method
public typealias APIParameters = Alamofire.Parameters
public typealias APIPlugins = [RxNetworks.PluginSubType]
public typealias APIStubBehavior = Moya.StubBehavior
public typealias APISuccessJSON = Any
public typealias APIFailureError = Swift.Error
public typealias APIResponseResult = Result<Moya.Response, MoyaError>

public typealias APISuccess = (_ json: APISuccessJSON) -> Void
public typealias APIFailure = (_ error: APIFailureError) -> Void
public typealias APIComplete = (_ result: Result<APISuccessJSON, APIFailureError>) -> Void

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
    
    /// Remove all HUDs displayed to `LevelStatusBarWindowController`.
    func removeHUD()
    
    /// Remove  displaying in the window`NetworkConfig.loadingPluginNames` loading.
    func removeLoading()
}
