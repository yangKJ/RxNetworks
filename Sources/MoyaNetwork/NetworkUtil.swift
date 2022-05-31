//
//  NetworkUtil.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

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
    
    @discardableResult
    static func beginRequest(_ api: NetworkAPI,
                             base: MoyaProvider<MultiTarget>,
                             queue: DispatchQueue?,
                             success: @escaping APISuccess,
                             failure: @escaping APIFailure,
                             progress: ProgressBlock? = nil) -> Cancellable {
        let target = MultiTarget.target(api)
        let tempPlugins = base.plugins
        return base.request(target, callbackQueue: queue, progress: progress, completion: { result in
            var _result = result
            var _mapResult: MapJSONResult?
            if let plugins = tempPlugins as? [PluginSubType] {
                // last never handy data, last chance
                let tuple = NetworkUtil.handyLastNeverPlugin(plugins, result: _result, target: target)
                if tuple.againRequest == true {
                    beginRequest(api, base: base, queue: queue, success: success, failure: failure, progress: progress)
                    return
                }
                _result = tuple.result
                _mapResult = tuple.mapResult
            }
            
            if let _mapResult = _mapResult {
                switch _mapResult {
                case let .success(json):
                    success(json)
                case let .failure(error):
                    failure(error)
                }
            } else {
                switch _result {
                case let .success(response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let json = try response.mapJSON()
                        success(json)
                    } catch MoyaError.statusCode(let response) {
                        failure(MoyaError.statusCode(response))
                    } catch MoyaError.jsonMapping(let response) {
                        failure(MoyaError.jsonMapping(response))
                    } catch {
                        failure(error)
                    }
                case let .failure(error):
                    failure(error)
                }
            }
        })
    }
}
