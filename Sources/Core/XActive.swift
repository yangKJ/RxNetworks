//
//  XActive.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//

import Foundation
import Moya

// MARK: - 模块宏定义
extension RxNetworks.X {
    
    /// 注入默认插件
    static func defaultPlugin(_ plugins: inout APIPlugins) {
        var plugins_ = plugins
        if let others = NetworkConfig.basePlugins {
            plugins_ += others
        }
        #if RXNETWORKS_PLUGINGS_INDICATOR
        if NetworkConfig.addIndicator, !plugins_.contains(where: { $0 is NetworkIndicatorPlugin}) {
            let Indicator = NetworkIndicatorPlugin.shared
            plugins_.insert(Indicator, at: 0)
        }
        #endif
        #if DEBUG && RXNETWORKS_PLUGINGS_DEBUGGING
        if NetworkConfig.addDebugging, !plugins_.contains(where: { $0 is NetworkDebuggingPlugin}) {
            let Debugging = NetworkDebuggingPlugin.init()
            plugins_.append(Debugging)
        }
        #endif
        plugins = plugins_
    }
    
    /// 是否存在共享网络插件
    static func hasNetworkSharedPlugin(_ plugins: APIPlugins) -> Bool {
        #if RXNETWORKS_PLUGINGS_SHARED
        return plugins.contains(where: { $0 is NetworkSharedPlugin })
        #else
        return false
        #endif
    }
    
    /// 是否存在失败提示插件
    static func hasNetworkWarningPlugin(_ plugins: APIPlugins?) -> Bool {
        guard let plugins = plugins else {
            return false
        }
        #if RXNETWORKS_PLUGINGS_WARNING
        return plugins.contains(where: { $0 is NetworkWarningPlugin })
        #else
        return false
        #endif
    }
    
    /// 是否存在请求头插件
    static func hasNetworkHttpHeaderPlugin(_ plugins: APIPlugins) -> [String: String]? {
        #if RXNETWORKS_PLUGINGS_HTTPHEADER
        var plugins = plugins
        if let others = NetworkConfig.basePlugins {
            plugins += others
        }
        if let p = plugins.first(where: { $0 is NetworkHttpHeaderPlugin }) {
            return (p as? NetworkHttpHeaderPlugin)?.dictionary
        }
        #endif
        return nil
    }
}

// MARK: - 网络相关
extension RxNetworks.X {
    
    static func requestLink(with target: TargetType) -> String {
        /// 参数排序生成字符串
        let sort = { (_ parameters: [String: Any]?) -> String in
            guard let params = parameters, !params.isEmpty else {
                return ""
            }
            var paramString = "?"
            let sorteds = params.sorted(by: { $0.key > $1.key })
            for index in sorteds.indices {
                paramString.append("\(sorteds[index].key)=\(sorteds[index].value)")
                if index != sorteds.count - 1 { paramString.append("&") }
            }
            return paramString
        }
        var parameters: APIParameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        let paramString = sort(parameters)
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
    
    static func toJSON(with response: Moya.Response) throws -> APISuccessJSON {
        let response = try response.filterSuccessfulStatusCodes()
        return try response.mapJSON()
    }
    
    static func loadingSuffix(key: SharedDriver.Key?) -> Bool {
        guard let key = key else { return false }
        if let suffix = key.components(separatedBy: "_").last, NetworkConfig.loadingPluginNames.contains(suffix) {
            return true
        }
        return false
    }
    
    static func setupPluginsAndKey(_ key: String, plugins: APIPlugins) -> APIPlugins {
        return plugins.map({
            if var plugin = $0 as? PluginPropertiesable {
                plugin.plugins = plugins
                plugin.key = key + "_" + plugin.pluginName
                return plugin
            }
            return $0
        })
    }
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> HeadstreamRequest {
        var request = HeadstreamRequest()
        plugins.forEach { request = $0.configuration(request, target: target) }
        return request
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins,
                                     result: Result<Moya.Response, MoyaError>,
                                     target: TargetType,
                                     onNext: @escaping (LastNeverResult)-> Void) {
        var lastResult = LastNeverResult.init(result: result)
        var iterator = plugins.makeIterator()
        func handleLastNever(_ plugin: RxNetworks.PluginSubType?) {
            guard let plugin = plugin else {
                onNext(lastResult)
                return
            }
            plugin.lastNever(lastResult, target: target) {
                lastResult = $0
                handleLastNever(iterator.next())
            }
        }
        handleLastNever(iterator.next())
    }
    
    @discardableResult static func request(target: MultiTarget,
                                           provider: MoyaProvider<MultiTarget>,
                                           queue: DispatchQueue?,
                                           success: @escaping APISuccess,
                                           failure: @escaping APIFailure,
                                           progress: ProgressBlock? = nil) -> Cancellable {
        return provider.request(target, callbackQueue: queue, progress: progress, completion: { result in
            guard let plugins = provider.plugins as? [PluginSubType] else {
                let lastResult = LastNeverResult(result: result)
                lastResult.handy(success: success, failure: failure)
                return
            }
            handyLastNeverPlugin(plugins, result: result, target: target) { lastResult in
                if lastResult.againRequest {
                    request(target: target, provider: provider, queue: queue, success: success, failure: failure, progress: progress)
                    return
                }
                lastResult.handy(success: success, failure: failure)
            }
        })
    }
}
