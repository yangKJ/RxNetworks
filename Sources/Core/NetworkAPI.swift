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

public typealias APISuccess = (_ json: APISuccessJSON) -> Void
public typealias APIFailure = (_ error: APIFailureError) -> Void

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
}

extension NetworkAPI {
    /// 获取到指定插件
    public func givenPlugin<T: RxNetworks.PluginSubType>(type: T.Type) -> T? {
        guard let plugin = plugins.first(where: { $0 is T }) as? T else {
            return nil
        }
        return plugin
    }
    
    /// 移除HUD
    public func removeHUD() {
        SharedDriver.shared.readHUD(prefix: keyPrefix).forEach {
            X.removeHUD(key: $0.key)
            $0.close()
        }
    }
    
    /// 移除加载Loading
    public func removeLoading() {
        let vcs = SharedDriver.shared.readHUD(prefix: keyPrefix)
        for vc in vcs where X.loadingSuffix(key: vc.key) {
            X.removeHUD(key: vc.key)
            vc.close()
        }
    }
}
