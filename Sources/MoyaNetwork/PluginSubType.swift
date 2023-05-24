//
//  PluginSubType.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 继承Moya插件协议，方便后序扩展，所有插件方法都必须实现该协议
/// Inherit the Moya plug-in protocol, which is convenient for subsequent expansion. All plug-in methods must implement this protocol
public protocol PluginSubType: Moya.PluginType {
    
    /// 插件名
    var pluginName: String { get }
    
    /// 设置网络配置信息之后，开始准备请求之前，
    /// 该方法可以用于本地缓存存在时直接抛出数据而不用再执行后序网络请求等场景
    /// - Parameters:
    ///   - tuple: 配置信息元组，其中包含数据源和是否结束后序网络请求
    ///   - target: 参数协议
    ///   - plugins: 配置的插件数组
    /// - Returns: 包涵数据源和是否结束后序网络请求的元组
    ///
    /// After setting the network configuration information, before starting to prepare the request,
    /// This method can be used in scenarios such as throwing data directly when the local cache exists without executing subsequent network requests.
    /// - Parameters:
    ///   - tuple: A tuple of configuration information, which contains the data source and whether to end the subsequent network request.
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - plugins: Array of configured plugins.
    /// - Returns: The tuple containing the data source and whether to end the subsequent network request.
    func configuration(_ tuple: ConfigurationTuple, target: TargetType, plugins: APIPlugins) -> ConfigurationTuple
    
    /// 最后的最后网络响应返回时刻，
    /// 该方法可以用于密钥失效重新去获取密钥然后自动再次网络请求等场景
    /// - Parameters:
    ///   - tuple: 自动再次元组，其中包含数据源和是否自动上次网络请求
    ///   - target: 参数协议
    ///   - onNext: 给插件异步处理任务，回调包含数据源和是否再次开启上次网络请求的元组
    ///
    /// The last time the last network response is returned,
    /// This method can be used in scenarios such as key invalidation to obtain the key again and then automatically request the network again.
    /// - Parameters:
    ///   - tuple: Auto-repeat tuple containing the data source and whether auto-last network request.
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - onNext: Provide callbacks for the plug-in to process tasks asynchronously.
    func lastNever(_ tuple: LastNeverTuple, target: TargetType, onNext: @escaping LastNeverCallback)
}

extension PluginSubType {
    
    public func configuration(_ tuple: ConfigurationTuple, target: TargetType, plugins: APIPlugins) -> ConfigurationTuple {
        return tuple
    }
    
    public func lastNever(_ tuple: LastNeverTuple, target: TargetType, onNext: @escaping LastNeverCallback) {
        onNext(tuple)
    }
}
