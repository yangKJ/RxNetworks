//
//  NetworkAPI.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

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
}

extension NetworkAPI {
    /// 获取到指定插件
    public func givenPlugin<T: RxNetworks.PluginSubType>(type: T.Type) -> T? {
        guard let plugin = plugins.first(where: { $0 is T }) as? T else {
            return nil
        }
        return plugin
    }
}
