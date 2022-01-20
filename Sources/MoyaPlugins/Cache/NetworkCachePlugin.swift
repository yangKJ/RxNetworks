//
//  NetworkCachePlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import Moya
import YYCache
import CommonCrypto

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
    /** 先从缓存读取数据，然后在从网络获取并且缓存，缓存数据通过闭包丢出去 */
    /** First read the data from the cache, then get it from the network and cache it, the cached data is thrown out through the closure */
    case cacheThenNetwork
}

/// 缓存插件，基于YYCache封装使用
/// Cache plug-in, based on YYCache package use
public final class NetworkCachePlugin {
    
    static let kCacheName = "ykj.Network.cache.plugin"
    private lazy var cache: YYCache? = {
        let cache = YYCache.init(name: NetworkCachePlugin.kCacheName)
        if let cache = cache {
            cache.memoryCache.countLimit = CacheManager.maxCountLimit
            cache.memoryCache.costLimit = CacheManager.maxCostLimit
        }
        return cache
    }()
    
    /// Network cache plugin type
    let cacheType: NetworkCacheType
    /// Cached data closure callback of type `cacheThenNetwork`
    let completion: Moya.Completion?
    
    /// Initialize
    /// - Parameters:
    ///   - cacheType: Network cache type
    ///   - completion: The cached data closure callback of type `cacheThenNetwork`
    public init(cacheType: NetworkCacheType = NetworkCacheType.ignoreCache,
                completion: Moya.Completion? = nil) {
        self.cacheType = cacheType
        self.completion = completion
    }
}

extension NetworkCachePlugin: PluginSubType {
    
    public func configuration(_ tuple: ConfigurationTuple, target: TargetType) -> ConfigurationTuple {
        if self.cacheType == NetworkCacheType.cacheElseNetwork, let response = self.readCacheResponse(target) {
            return (.success(response), true)
        }
        return tuple
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if self.cacheType == NetworkCacheType.cacheThenNetwork {
            if let completion = completion, let response = self.readCacheResponse(target) {
                completion(.success(response))
            }
        }
        return request
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            switch self.cacheType {
            case NetworkCacheType.networkElseCache,
                NetworkCacheType.cacheThenNetwork,
                NetworkCacheType.cacheElseNetwork:
                self.saveCacheResponse(response, target: target)
            default:
                break
            }
        case .failure(_): break
        }
    }
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if self.cacheType == NetworkCacheType.networkElseCache {
            switch result {
            case .success(_): return result
            case .failure(_):
                if let cacheResponse = self.readCacheResponse(target) {
                    return .success(cacheResponse)
                }
            }
        }
        return result
    }
}

extension NetworkCachePlugin {
    
    private func readCacheResponse(_ target: TargetType) -> Moya.Response? {
        guard let cache = self.cache else { return nil }
        
        let link = requestFullLink(with: target)
        let key = NetworkCachePlugin.MD5(link)
        guard let dict = cache.object(forKey: key) as? NSDictionary,
              let statusCode = dict.value(forKey: "statusCode") as? Int,
              let data = dict.value(forKey: "data") as? Data else {
                  return nil
              }
        let response = Response(statusCode: statusCode, data: data)
        
        return response
    }
    
    private func saveCacheResponse(_ response: Moya.Response?, target: TargetType) {
        guard let response = response, let cache = self.cache else { return }
        
        let link = requestFullLink(with: target)
        let key = NetworkCachePlugin.MD5(link)
        let storage: NSDictionary = [
            //"key": key,
            //"link": link,
            "data": response.data,
            "statusCode": response.statusCode
        ]
        cache.setObject(storage, forKey: key)
    }
    
    private func requestFullLink(with target: TargetType) -> String {
        var parameters: APIParameters? = nil
        switch target.task {
        case .requestParameters(let p, _):
            parameters = p
        default:
            break
        }
        guard let parameters = parameters, !parameters.isEmpty else {
            return target.baseURL.absoluteString + target.path
        }
        let sortedParameters = parameters.sorted(by: { $0.key > $1.key })
        var paramString = "?"
        for index in sortedParameters.indices {
            paramString.append("\(sortedParameters[index].key)=\(sortedParameters[index].value)")
            if index != sortedParameters.count - 1 { paramString.append("&") }
        }
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
    
    /// MD5
    private static func MD5(_ string: String) -> String {
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
}
