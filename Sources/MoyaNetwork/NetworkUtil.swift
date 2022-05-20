//
//  NetworkUtil.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import Foundation
import Moya

internal struct NetworkUtil {
    
    static func defaultPlugin(_ plugins: inout APIPlugins, api: NetworkAPI) {
        var temp = plugins
        if let injection = NetworkConfig.injectionPlugins, !injection.isEmpty {
            temp += injection
        }
        if NetworkConfig.addIndicator {
            #if RxNetworks_MoyaPlugins_Indicator
            if !temp.contains(where: { $0 is NetworkIndicatorPlugin}) {
                let Indicator = NetworkIndicatorPlugin.init()
                temp.insert(Indicator, at: 0)
            }
            #endif
        }
        if NetworkConfig.addDebugging {
            #if DEBUG && RxNetworks_MoyaPlugins_Debugging
            if !temp.contains(where: { $0 is NetworkDebuggingPlugin}) {
                let Debugging = NetworkDebuggingPlugin.init()
                temp.append(Debugging)
            }
            #endif
        }
        plugins = temp
    }
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> ConfigurationTuple {
        var tuple: ConfigurationTuple
        tuple.result = nil // Empty data, convenient for subsequent plugin operations
        tuple.endRequest = false
        tuple.session = nil
        plugins.forEach { tuple = $0.configuration(tuple, target: target, plugins: plugins) }
        return tuple
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins, result: MoyaResult, target: TargetType) -> LastNeverTuple {
        var tuple: LastNeverTuple
        tuple.result = result
        tuple.againRequest = false
        tuple.mapResult = nil
        plugins.forEach { tuple = $0.lastNever(tuple, target: target) }
        return tuple
    }
}
