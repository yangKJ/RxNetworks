//
//  NetworkAPI+Ext.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya

/// 协议默认实现方案
/// Protocol default implementation scheme
extension NetworkAPI {
    public var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    public var parameters: APIParameters? {
        return nil
    }
    
    public var plugins: APIPlugins {
        return []
    }
    
    public var stubBehavior: APIStubBehavior {
        return APIStubBehavior.never
    }
    
    public var retry: APINumber {
        return 0
    }
    
    public var keyPrefix: String {
        let string = ip + path + X.sortParametersToString(parameters)
        return MD5.init().hex_md5(string)
    }
    
    public var httpShouldHandleCookies: Bool {
        return true
    }
    
    public var sampleResponse: Moya.EndpointSampleResponse {
        return .networkResponse(200, self.sampleData)
    }
    
    public var mapped2JSON: Bool {
        return BoomingSetup.mapped2JSON
    }
    
    public func removeHUD() {
        HUDs.readHUD(prefix: keyPrefix).forEach {
            HUDs.removeHUD(key: $0.key)
            $0.close()
        }
    }
    
    public func removeLoading() {
        let vcs = HUDs.readHUD(prefix: keyPrefix)
        for vc in vcs where HUDs.loadingHUDsSuffix(key: vc.key) {
            HUDs.removeHUD(key: vc.key)
            vc.close()
        }
    }
}

// MARK: - Moya
extension NetworkAPI {
    public var baseURL: URL {
        return URL(string: ip)!
    }
    
    public var path: APIPath {
        return ""
    }
    
    public var method: APIMethod {
        return BoomingSetup.baseMethod
    }
    
    public var headers: [String: String]? {
        return nil
    }
    
    public var task: Moya.Task {
        let param = BoomingSetup.baseParameters.merging(parameters ?? [:]) { $1 }
        switch method {
        case APIMethod.get:
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case APIMethod.post:
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        default:
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }
}
