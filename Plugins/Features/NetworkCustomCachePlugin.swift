//
//  NetworkCustomCachePlugin.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import Moya

public struct NetworkCustomCachePlugin {
    
    public let cacher: any ResponseCacheConvertible
    
    public let cacheType: NetworkCacheType
    
    public init(cacheType: NetworkCacheType = .ignoreCache, cacher: any ResponseCacheConvertible) {
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
        return try? cacher.readResponse(forKey: cacheType.cacheKey(with: target))
    }
    
    private func saveCacheResponse(result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            switch cacheType {
            case .networkElseCache, .cacheThenNetwork, .cacheElseNetwork:
                try? cacher.saveResponse(response, forKey: cacheType.cacheKey(with: target))
            default:
                break
            }
        }
    }
}
