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
    
    /// 注入默认插件
    static func setupBasePlugins(_ plugins: inout APIPlugins) {
        var plugins_ = plugins
        if let others = BoomingSetup.basePlugins {
            plugins_ += others
        }
        #if BOOMING_PLUGINGS_INDICATOR
        if BoomingSetup.addIndicator, !plugins_.contains(where: { $0 is NetworkIndicatorPlugin}) {
            let Indicator = NetworkIndicatorPlugin.shared
            plugins_.insert(Indicator, at: 0)
        }
        #endif
        #if DEBUG && BOOMING_PLUGINGS_DEBUGGING
        if BoomingSetup.addDebugging, !plugins_.contains(where: { $0 is NetworkDebuggingPlugin}) {
            let Debugging = NetworkDebuggingPlugin.init()
            plugins_.append(Debugging)
        }
        #endif
        plugins = plugins_
    }
    
    /// 是否存在共享网络插件
    static func hasNetworkSharedPlugin(_ plugins: APIPlugins) -> Bool {
        #if BOOMING_PLUGINGS_SHARED
        return plugins.contains(where: { $0 is NetworkSharedPlugin })
        #else
        return false
        #endif
    }
    
    /// 是否存在请求头插件
    static func hasNetworkHttpHeaderPlugin(_ key: String) -> [String: String]? {
        #if BOOMING_PLUGINGS_HTTPHEADER
        let plugins = SharedDriver.shared.readRequestPlugins(key)
        if let p = plugins.first(where: { $0 is NetworkHttpHeaderPlugin }) {
            return (p as? NetworkHttpHeaderPlugin)?.dictionary
        }
        #endif
        return nil
    }
    
    /// 上传下载插件
    static func hasNetworkFilesPluginTask(_ key: String) -> Moya.Task? {
        #if BOOMING_PLUGINGS_DOWNLOAD_UPLOAD
        let plugins = SharedDriver.shared.readRequestPlugins(key)
        if let p = plugins.first(where: { $0 is NetworkFilesPlugin }) {
            return (p as? NetworkFilesPlugin)?.task
        }
        #endif
        return nil
    }
    
    static func hasNetworkFilesPlugin(_ plugins: APIPlugins) -> URL? {
        #if BOOMING_PLUGINGS_DOWNLOAD_UPLOAD
        if let p = plugins.first(where: { $0 is NetworkFilesPlugin }) {
            return (p as? NetworkFilesPlugin)?.downloadAssetURL
        }
        #endif
        return nil
    }
}

// MARK: - 网络相关
extension X {
    
    static func maxDelayTime(with plugins: APIPlugins) -> Double {
        let times: [Double] = plugins.compactMap {
            if let p = $0 as? PluginPropertiesable {
                return p.delay
            }
            return nil
        }
        let maxTime = times.max() ?? 0.0
        return maxTime
    }
    
    static func sortParametersToString(_ parameters: APIParameters?) -> String {
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
    
    static func toJSON(with response: Moya.Response) throws -> APISuccessJSON {
        let response = try response.filterSuccessfulStatusCodes()
        return try response.mapJSON(failsOnEmptyData: BoomingSetup.failsOnEmptyData)
    }
    
    static func loadingSuffix(key: SharedDriver.Key?) -> Bool {
        guard let key = key else { return false }
        if let suffix = key.components(separatedBy: "_").last, BoomingSetup.loadingPluginNames.contains(suffix) {
            return true
        }
        return false
    }
    
    static func setupPluginsAndKey(_ key: String, plugins: APIPlugins) -> APIPlugins {
        var plugins = plugins
        X.setupBasePlugins(&plugins)
        return plugins.map({
            if var plugin = $0 as? PluginPropertiesable {
                plugin.plugins = plugins
                plugin.key = key + "_" + plugin.pluginName
                return plugin
            }
            return $0
        })
    }
}
