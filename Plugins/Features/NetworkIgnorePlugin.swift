//
//  NetworkIgnorePlugin.swift
//  Booming
//
//  Created by Condy on 2024/6/1.
//

import Foundation
import Moya

/// 忽略插件，目的在于本次网络请求忽略某款插件
/// 场景：假如你在默认插件中加入过白盒密钥插件，但个例网络请求又不需该插件，则需单独移除；
public struct NetworkIgnorePlugin {
    
    /// This network request will ignore the plug-ins that have been added.
    public let ignorePluginTypes: [PluginSubType.Type]
    
    public init(pluginTypes: [PluginSubType.Type]) {
        self.ignorePluginTypes = pluginTypes
    }
    
    func removePlugins(_ plugins: APIPlugins) -> APIPlugins {
        guard !ignorePluginTypes.isEmpty else {
            return plugins
        }
        var plugins_ = plugins
        plugins_.removeAll {
            let className = $0.className
            return ignorePluginTypes.contains {
                $0.className == className
            }
        }
        return plugins_
    }
}

extension NetworkIgnorePlugin: PluginSubType {
    
    public var pluginName: String {
        return "Ignore"
    }
}
