//
//  NetworkAPI+Ext.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya
import CommonCrypto

/// 协议默认实现方案
/// Protocol default implementation scheme
extension NetworkAPI {
    public var ip: APIHost {
        return NetworkConfig.baseURL
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
        let paramString = RxNetworks.X.sortParametersToString(parameters)
        let string = ip + path + paramString
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
    
    public func removeHUD() {
        SharedDriver.shared.readHUD(prefix: keyPrefix).forEach {
            X.removeHUD(key: $0.key)
            $0.close()
        }
    }
    
    public func removeLoading() {
        let vcs = SharedDriver.shared.readHUD(prefix: keyPrefix)
        for vc in vcs where X.loadingSuffix(key: vc.key) {
            X.removeHUD(key: vc.key)
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
        return NetworkConfig.baseMethod
    }
    
    public var headers: [String: String]? {
        return nil
    }
    
    public var task: Moya.Task {
        let param = NetworkConfig.baseParameters.merging(parameters ?? [:]) { $1 }
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
