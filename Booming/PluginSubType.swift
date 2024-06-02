//
//  PluginSubType.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public protocol HasPluginsPropertyProtocol: PluginSubType {
    var plugins: APIPlugins { get set }
}

@available(*, deprecated, message: "Typo. Use `HasKeyAndDelayPropertyProtocol` instead", renamed: "HasKeyAndDelayPropertyProtocol")
public typealias PluginPropertiesable = HasKeyAndDelayPropertyProtocol

public protocol HasKeyAndDelayPropertyProtocol: PluginSubType {
    
    var key: String? { get set }
    
    /// Loading HUD delay hide time.
    var delay: Double { get }
}

extension HasKeyAndDelayPropertyProtocol {
    public var delay: Double {
        return 0
    }
}

/// 继承Moya插件协议，方便后序扩展，所有插件方法都必须实现该协议
/// Inherit the Moya plug-in protocol, which is convenient for subsequent expansion. All plug-in methods must implement this protocol
public protocol PluginSubType: Moya.PluginType {
    
    static var className: String { get }
    
    var className: String { get }
    
    /// 插件名
    var pluginName: String { get }
    
    /// 优先等级，解决某些插件需要先后顺序问题
    /// 场景：比如解析插件和解压插件甚至加解密插件，至少就需要先解压再解密最后才是解析数据。
    var usePriorityLevel: UsePriorityLevel { get }
    
    /// 设置网络配置信息之后，开始准备请求之前，
    /// 该方法可以用于本地缓存存在时直接抛出数据而不用再执行后序网络请求等场景
    /// - Parameters:
    ///   - request: 配置信息，其中包含数据源和是否结束后序网络请求
    ///   - target: 参数协议
    /// - Returns: 包涵数据源和是否结束后序网络请求
    ///
    /// After setting the network configuration information, before starting to prepare the request,
    /// This method can be used in scenarios such as throwing data directly when the local cache exists without executing subsequent network requests.
    /// - Parameters:
    ///   - request: Configuration information, which contains the data source and whether to end the subsequent network request.
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: Containing the data source and whether to end the subsequent network request.
    func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest
    
    /// 最后的最后网络响应返回时刻，
    /// 该方法可以用于密钥失效重新去获取密钥然后自动再次网络请求等场景
    /// - Parameters:
    ///   - result: 包含数据源和是否自动上次网络请求
    ///   - target: 参数协议
    ///   - onNext: 给插件异步处理任务，回调包含数据源和是否再次开启上次网络请求的元组
    ///
    /// The last time the last network response is returned,
    /// This method can be used in scenarios such as key invalidation to obtain the key again and then automatically request the network again.
    /// - Parameters:
    ///   - result: Containing the data source and whether auto-last network request.
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - onNext: Provide callbacks for the plug-in to process tasks asynchronously.
    func lastNever(_ result: OutputResult, target: TargetType, onNext: @escaping LastNeverCallback)
}

extension PluginSubType {
    
    public static var className: String {
        String(describing: self)
    }
    
    public var className: String {
        String(describing: type(of: self))
    }
    
    public var usePriorityLevel: UsePriorityLevel {
        UsePriorityLevel.medium
    }
    
    public func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest {
        return request
    }
    
    public func lastNever(_ result: OutputResult, target: TargetType, onNext: @escaping LastNeverCallback) {
        onNext(result)
    }
}
