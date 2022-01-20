//
//  NetworkUtil.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import Foundation
import Moya
import RxSwift

internal struct NetworkUtil {
    
    /// 默认指定插件
    /// - Parameter plugins: 插件数组
    static func defaultPlugin(_ plugins: inout APIPlugins, api: NetworkAPI) {
        var temp = plugins
        #if RxNetworks_MoyaPlugins_Indicator
        if !temp.contains(where: { $0 is NetworkIndicatorPlugin}) {
            let Indicator = NetworkIndicatorPlugin.init()
            temp.insert(Indicator, at: 0)
        }
        #endif
        #if DEBUG && RxNetworks_MoyaPlugins_Debugging
        if !temp.contains(where: { $0 is NetworkDebuggingPlugin}) {
            let Debugging = NetworkDebuggingPlugin(api: api)
            temp.append(Debugging)
        }
        #endif
        plugins = temp
    }
    
    static func transformAPISingleJSON(_ result: MoyaResultable) -> APISingleJSON {
        return APISingleJSON.create { single in
            if let result = result {
                switch result {
                case let .success(response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let json = try response.mapJSON()
                        single(.success(json))
                    } catch MoyaError.jsonMapping(let response) {
                        single(.failure(MoyaError.jsonMapping(response)))
                    } catch MoyaError.statusCode(let response) {
                        single(.failure(MoyaError.statusCode(response)))
                    } catch {
                        single(.failure(error))
                    }
                case let .failure(error):
                    single(.failure(error))
                }
            }
            return Disposables.create { }
        }
    }
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> ConfigurationTuple {
        var tuple: ConfigurationTuple
        tuple.result = nil // 空数据，方便后序插件操作
        tuple.endRequest = false
        plugins.forEach { tuple = $0.configuration(tuple, target: target) }
        return tuple
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins, target: TargetType, single: APISingleJSON) -> Bool {

        // TODO: 项目暂时未使用，有时间再来完善
        // TODO: The project has not been used for the time being, and it will be improved when there is time.
        return false
    }
}
