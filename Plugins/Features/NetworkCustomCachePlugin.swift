//
//  NetworkCustomCachePlugin.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import Moya

/// Any caching schema that complies with the protocol can use the `NetworkCustomCachePlugin`.
public protocol CacheConvertable {
    
    func readResponse(forKey key: String) throws -> Moya.Response?
    
    func saveResponse(_ response: Moya.Response, forKey key: String) throws
    
    func clearAllResponses()
}

public struct NetworkCustomCachePlugin {
    
    /// Network cache plugin type
    public enum CacheType {
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
    
    public let cacher: any CacheConvertable
    
    public let cacheType: CacheType
    
    public init(cacheType: CacheType = .ignoreCache, cacher: any CacheConvertable) {
        self.cacheType = cacheType
        self.cacher = cacher
    }
}

extension NetworkCustomCachePlugin: PluginSubType {
    
    public var pluginName: String {
        return "CustomCache"
    }
    
    public func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest {
        switch cacheType {
        case .cacheElseNetwork, .cacheThenNetwork:
            if let response = self.readCacheResponse(target) {
                request.result = .success(response)
            }
            if cacheType == .cacheElseNetwork {
                request.endRequest = true
            }
        default:
            break
        }
        return request
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        saveCacheResponse(result: result, target: target)
    }
    
    public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
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

extension NetworkCustomCachePlugin {
    
    private func readCacheResponse(_ target: TargetType) -> Moya.Response? {
        return try? cacher.readResponse(forKey: cacheKey(with: target))
    }
    
    private func saveCacheResponse(result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            switch cacheType {
            case .networkElseCache, .cacheThenNetwork, .cacheElseNetwork:
                try? cacher.saveResponse(response, forKey: cacheKey(with: target))
            default:
                break
            }
        }
    }
    
    private func cacheKey(with target: TargetType) -> String {
        if let api = target as? NetworkAPI {
            let paramString = X.sortParametersToString(api.parameters)
            return target.baseURL.absoluteString + target.path + paramString
        } else if let multiTarget = target as? MultiTarget, let api = multiTarget.target as? NetworkAPI {
            let paramString = X.sortParametersToString(api.parameters)
            return target.baseURL.absoluteString + target.path + paramString
        }
        return target.baseURL.absoluteString + target.path
    }
}
