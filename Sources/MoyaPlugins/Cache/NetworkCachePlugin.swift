//
//  NetworkCachePlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// Network cache plugin type
public enum NetworkCacheType {
    /** 只从网络获取数据，且数据不会缓存在本地 */
    /** Only get data from the network, and the data will not be cached locally */
    case ignoreCache
    /** 先从网络获取数据，同时会在本地缓存数据 */
    /** Get the data from the network first, and cache the data locally at the same time */
    case networkOnly
    /** 先从缓存读取数据，如果没有再从网络获取 */
    /** Read the data from the cache first, if not, then get it from the network */
    case cacheElseNetwork
    /** 先从网络获取数据，如果没有在从缓存获取，此处的没有可以理解为访问网络失败，再从缓存读取 */
    /** Get data from the network first, if not from the cache */
    case networkElseCache
    /** 先从缓存读取数据，然后在从网络获取并且缓存，可能会获取到两次数据 */
    /** Data is first read from the cache, then retrieved from the network and cached, Maybe get `twice` data */
    case cacheThenNetwork
}

/// 缓存插件，基于`YYCache`封装使用
/// Cache plugin, based on `YYCache` package use
public final class NetworkCachePlugin {
    
    /// Network cache plugin type
    let cacheType: NetworkCacheType
    
    /// Encryption type, default md5
    var cryptoType: CryptoType = .md5
    
    /// Initialize
    /// - Parameters:
    ///   - cacheType: Network cache type
    ///   - completion: The cached data closure callback of type `cacheThenNetwork`
    public init(cacheType: NetworkCacheType = NetworkCacheType.ignoreCache) {
        self.cacheType = cacheType
    }
}

extension NetworkCachePlugin: PluginSubType {
    
    public var pluginName: String {
        return "Cache"
    }
    
    public func configuration(_ tuple: ConfigurationTuple, target: TargetType, plugins: APIPlugins) -> ConfigurationTuple {
        if (cacheType == .cacheElseNetwork || cacheType == .cacheThenNetwork), let response = self.readCacheResponse(target) {
            if cacheType == .cacheElseNetwork {
                return (.success(response), true, tuple.session)
            } else {
                return (.success(response), false, tuple.session)
            }
        }
        return tuple
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            switch self.cacheType {
            case .networkElseCache, .cacheThenNetwork, .cacheElseNetwork:
                self.saveCacheResponse(response, target: target)
            default:
                break
            }
        }
    }
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch cacheType {
        case .networkElseCache:
            switch result {
            case .success:
                return result
            case .failure:
                if let response = self.readCacheResponse(target) {
                    return .success(response)
                }
            }
        default:
            break
        }
        return result
    }
}

extension NetworkCachePlugin {
    
    private func readCacheResponse(_ target: TargetType) -> Moya.Response? {
        let key = cryptoType.encryptedString(with: requestLink(with: target))
        guard let model = CacheManager.default.fetchCached(forKey: key),
              let statusCode = model.statusCode,
              let data = model.data else {
            return nil
        }
        return Response(statusCode: statusCode, data: data)
    }
    
    private func saveCacheResponse(_ response: Moya.Response?, target: TargetType) {
        guard let response = response else { return }
        let key = cryptoType.encryptedString(with: requestLink(with: target))
        var model = CacheModel()
        model.data = response.data
        model.statusCode = response.statusCode
        CacheManager.default.saveCached(model, forKey: key)
    }
    
    private func requestLink(with target: TargetType) -> String {
        var parameters: APIParameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        let paramString = sort(parameters: parameters)
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
    
    /// 参数排序生成字符串
    private func sort(parameters: [String: Any]?) -> String {
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
}
