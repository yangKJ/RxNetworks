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
        var plugins_ = plugins
        if let others = NetworkConfig.injectionPlugins {
            plugins_ += others
        }
        #if RxNetworks_MoyaPlugins_Indicator
        if NetworkConfig.addIndicator, !plugins_.contains(where: { $0 is NetworkIndicatorPlugin}) {
            let Indicator = NetworkIndicatorPlugin.shared
            plugins_.insert(Indicator, at: 0)
        }
        #endif
        #if DEBUG && RxNetworks_MoyaPlugins_Debugging
        if NetworkConfig.addDebugging, !plugins_.contains(where: { $0 is NetworkDebuggingPlugin}) {
            let Debugging = NetworkDebuggingPlugin.init()
            plugins_.append(Debugging)
        }
        #endif
        plugins = plugins_
    }
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> ConfigurationTuple {
        var tuple: ConfigurationTuple
        tuple.result = nil // Empty data, convenient for subsequent plugin operations
        tuple.endRequest = false
        tuple.session = nil
        plugins.forEach { tuple = $0.configuration(tuple, target: target, plugins: plugins) }
        return tuple
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins,
                                     result: MoyaResult,
                                     target: TargetType,
                                     onNext: @escaping (LastNeverTuple)-> Void) {
        var tuple: LastNeverTuple
        tuple.result = result
        tuple.againRequest = false
        tuple.mapResult = nil
        var iterator = plugins.makeIterator()
        func handleLastNever(_ plugin: RxNetworks.PluginSubType?) {
            guard let _plugin = plugin else {
                onNext(tuple)
                return
            }
            _plugin.lastNever(tuple, target: target) { __tuple in
                tuple = __tuple
                handleLastNever(iterator.next())
            }
        }
        handleLastNever(iterator.next())
    }
    
    @discardableResult
    static func beginRequest(_ api: NetworkAPI,
                             base: MoyaProvider<MultiTarget>,
                             queue: DispatchQueue?,
                             success: @escaping APISuccess,
                             failure: @escaping APIFailure,
                             progress: ProgressBlock? = nil) -> Cancellable {
        let target = MultiTarget.target(api)
        
        return base.request(target, callbackQueue: queue, progress: progress, completion: { result in
            guard let plugins = base.plugins as? [PluginSubType] else {
                // 主线程回调
                DispatchQueue.main.async {
                    Self.handleResult(result, nil, onSuccess: success, onFailure: failure)
                }
                return
            }
            
            NetworkUtil.handyLastNeverPlugin(plugins, result: result, target: target) { tuple in
                if tuple.againRequest {
                    beginRequest(api, base: base, queue: queue, success: success, failure: failure, progress: progress)
                    return
                }
                // 主线程回调
                DispatchQueue.main.async {
                    Self.handleResult(tuple.result, tuple.mapResult, onSuccess: success, onFailure: failure)
                }
            }
        })
    }
}

// MARK: - private methods

extension NetworkUtil {
    private static func handleResult(_ result: MoyaResult,
                                     _ jsonResult: MapJSONResult?,
                                     onSuccess: (_ json: Any) -> Void,
                                     onFailure: (_ error: Swift.Error) -> Void) {
        guard let _jsonResult = jsonResult else {
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let json = try response.mapJSON()
                    onSuccess(json)
                } catch MoyaError.statusCode(let response) {
                    onFailure(MoyaError.statusCode(response))
                } catch MoyaError.jsonMapping(let response) {
                    onFailure(MoyaError.jsonMapping(response))
                } catch {
                    onFailure(error)
                }
            case let .failure(error):
                onFailure(error)
            }
            return
        }
        switch _jsonResult {
        case let .success(json):
            onSuccess(json)
        case let .failure(error):
            onFailure(error)
        }
    }
}
