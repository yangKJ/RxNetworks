//
//  XActive.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

// MARK: - 模块宏定义
extension X {
    
    /// 配置所有插件
    static func setupPluginsAndKey(_ key: String, plugins: APIPlugins) -> APIPlugins {
        var plugins_ = plugins
        if let others = BoomingSetup.basePlugins {
            plugins_ += others
        }
        #if canImport(UIKit) && BOOMING_PLUGINGS_FEATURES
        if BoomingSetup.addIndicator, !plugins_.contains(where: { $0 is NetworkIndicatorPlugin}) {
            let Indicator = NetworkIndicatorPlugin.shared
            plugins_.insert(Indicator, at: 0)
        }
        #endif
        #if BOOMING_PLUGINGS_FEATURES
        if BoomingSetup.debuggingLogOption != .nothing, !plugins_.contains(where: { $0 is NetworkDebuggingPlugin}) {
            let logger = NetworkDebuggingPlugin.init(options: BoomingSetup.debuggingLogOption)
            plugins_.append(logger)
        }
        #endif
        let allPlugins = hasIgnorePlugin(plugins_).sorted(by: {
            $0.usePriorityLevel.rawValue < $1.usePriorityLevel.rawValue
        })
        return allPlugins.map({
            var midp = $0
            if var p = midp as? HasKeyAndDelayPropertyProtocol {
                p.key = key + "_" + midp.pluginName
                midp = p
            }
            if var p = midp as? HasPluginsPropertyProtocol {
                p.plugins = allPlugins
                midp = p
            }
            return midp
        })
    }
    
    /// 是否存在共享网络插件
    static func hasNetworkSharedPlugin(_ plugins: APIPlugins) -> Bool {
        #if BOOMING_PLUGINGS_FEATURES
        return plugins.contains(where: { $0 is NetworkSharedPlugin })
        #else
        return false
        #endif
    }
    
    /// 是否存在请求头插件
    static func hasNetworkHttpHeaderPlugin(_ plugins: APIPlugins) -> [String: String] {
        #if BOOMING_PLUGINGS_FEATURES
        if let p = plugins.first(where: { $0 is NetworkHttpHeaderPlugin }),
           let headers = (p as? NetworkHttpHeaderPlugin)?.dictionary {
            return headers
        }
        #endif
        return BoomingSetup.baseHeaders
    }
    
    /// 上传下载插件
    static func hasNetworkFilesPluginTask(_ plugins: APIPlugins) -> Moya.Task? {
        #if BOOMING_PLUGINGS_FEATURES
        if let p = plugins.first(where: { $0 is NetworkFilesPlugin }) {
            return (p as? NetworkFilesPlugin)?.task
        }
        #endif
        return nil
    }
    
    /// 下载文件链接
    static func hasNetworkFilesPlugin(_ plugins: APIPlugins) -> URL? {
        #if BOOMING_PLUGINGS_FEATURES
        if let p = plugins.first(where: { $0 is NetworkFilesPlugin }) {
            return (p as? NetworkFilesPlugin)?.downloadAssetURL
        }
        #endif
        return nil
    }
    
    /// 忽略插件
    static func hasIgnorePlugin(_ plugins: APIPlugins) -> APIPlugins {
        #if BOOMING_PLUGINGS_FEATURES
        if let p = plugins.first(where: { $0 is NetworkIgnorePlugin }),
           let value = (p as? NetworkIgnorePlugin)?.removePlugins(plugins) {
            return value
        }
        #endif
        return plugins
    }
    
    /// 拦截器插件
    static func hasAuthenticationPlugin(_ plugins: APIPlugins) -> RequestInterceptor? {
        #if BOOMING_PLUGINGS_FEATURES
        if let p = plugins.first(where: { $0 is NetworkAuthenticationPlugin }),
           let interceptor = (p as? NetworkAuthenticationPlugin)?.interceptor {
            return interceptor
        }
        #endif
        return BoomingSetup.interceptor
    }
}

// MARK: - 网络相关
extension X {
    
    static func maxDelayTime(with plugins: APIPlugins) -> TimeInterval {
        let times: [Double] = plugins.compactMap {
            if let p = $0 as? HasKeyAndDelayPropertyProtocol {
                return p.delay
            }
            return nil
        }
        let maxTime = times.max() ?? 0.0
        return maxTime
    }
    
    public static func sortParametersToString(_ parameters: APIParameters?) -> String {
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
    
    public static func requestLink(with target: TargetType, parameters: APIParameters? = nil) -> String {
        let parameters: APIParameters? = parameters ?? {
            if case .requestParameters(let parame, _) = target.task {
                return parame
            }
            return nil
        }()
        let paramString = sortParametersToString(parameters)
        return target.baseURL.absoluteString + target.path + paramString
    }
    
    static func toJSON(with response: Moya.Response) throws -> APIResultValue {
        let response = try response.filterSuccessfulStatusCodes()
        return try response.mapJSON(failsOnEmptyData: BoomingSetup.failsOnEmptyData)
    }
    
    static func safetyQueue(_ queue: DispatchQueue?) -> DispatchQueue {
        if let queue = queue {
            return (queue === DispatchQueue.main) ? queue : DispatchQueue(label: queue.label, target: queue)
        }
        return DispatchQueue(label: "condy.request.network.queue.\(UUID().uuidString)", attributes: [.concurrent])
    }
}
