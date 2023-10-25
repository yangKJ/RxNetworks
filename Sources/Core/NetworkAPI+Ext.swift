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
    
    // moya
    public var baseURL: URL {
        return URL(string: ip)!
    }
    
    public var path: APIPath {
        return ""
    }
    
    public var validationType: Moya.ValidationType {
        return Moya.ValidationType.successCodes
    }
    
    public var method: APIMethod {
        return NetworkConfig.baseMethod
    }
    
    public var sampleData: Data {
        return "{\"Condy\":\"yangkj310@gmail.com\"}".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        return X.setupHeaders(with: self)
    }
    
    public var task: Moya.Task {
        if let task_ = X.setupTask(with: self) {
            return task_
        }
        var param = NetworkConfig.baseParameters
        if let dict = parameters {
            // Merge the dictionaries and take the second value
            param = param.merging(dict) { $1 }
        }
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
