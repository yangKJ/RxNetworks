//
//  NetworkAPI+Ext.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import Foundation
import Alamofire
import RxSwift
import Moya

/// 协议默认实现方案
/// Protocol default implementation scheme
extension NetworkAPI {
    
    public func request() -> APIObservableJSON {
        return request(callbackQueue: nil)
    }
    
    public func request(callbackQueue: DispatchQueue?) -> APIObservableJSON {
        var tempPlugins: APIPlugins = self.plugins
        NetworkUtil.defaultPlugin(&tempPlugins, api: self)
        
        let target = MultiTarget.target(self)

        let tuple = NetworkUtil.handyConfigurationPlugin(tempPlugins, target: target)
        if tuple.endRequest == true {
            return NetworkUtil.transformAPIObservableJSON(tuple.result)
        }
        var session: Moya.Session
        if let _session = tuple.session {
            session = _session
        } else {
            let configuration = URLSessionConfiguration.af.default
            configuration.headers = Alamofire.HTTPHeaders.default
            configuration.timeoutIntervalForRequest = NetworkConfig.timeoutIntervalForRequest
            session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        }
        let provider = MoyaProvider<MultiTarget>(stubClosure: { _ in
            return stubBehavior
        }, session: session, plugins: tempPlugins)
        return provider.rx.request(api: self, callbackQueue: callbackQueue, result: tuple.result)
    }
}

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
        return "{\"Condy\":\"ykj310@126.com\"}".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        if NetworkConfig.baseHeaders.isEmpty {
            return ["Content-type": "application/json"]
        }
        return NetworkConfig.baseHeaders
    }
    
    public var task: Moya.Task {
        var param = NetworkConfig.baseParameters
        if let parameters = parameters {
            // Merge the dictionaries and take the second value
            param = NetworkConfig.baseParameters.merging(parameters) { $1 }
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
