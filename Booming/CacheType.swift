//
//  CacheType.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import Moya

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

extension CacheType {
    
    public func cacheKey(with target: TargetType) -> String {
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
