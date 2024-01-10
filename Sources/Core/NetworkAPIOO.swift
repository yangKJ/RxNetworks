//
//  NetworkAPIOO.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 面向对象编程，方便OC小伙伴的使用习惯，备注下面数据必须配套使用。
/// OOP, Convenient for the usage habits of OC partners
open class NetworkAPIOO {
    
    /// Request host
    public var cdy_ip: APIHost?
    /// Request path
    public var cdy_path: APIPath?
    /// Request parameters
    public var cdy_parameters: APIParameters?
    /// Request type
    public var cdy_method: APIMethod?
    /// Plugin array
    public var cdy_plugins: APIPlugins = []
    /// Failed retry count
    public var cdy_retry: APINumber = 0
    /// Test data, after setting the value of this property, only the test data is taken
    public var cdy_testJSON: String?
    /// Test data return time, the default is half a second
    public var cdy_testTime: Double = 0.5
    
    public init() { }
    
    @discardableResult
    open func cdy_request(complete: @escaping APIComplete, queue: DispatchQueue? = nil) -> Cancellable? {
        HTTPRequest(success: { json in
            complete(.success(json))
        }, failure: { error in
            complete(.failure(error))
        }, queue: queue)
    }
}

extension NetworkAPIOO: NetworkAPI {
    
    public var ip: APIHost {
        return cdy_ip ?? NetworkConfig.baseURL
    }
    
    public var path: String {
        return cdy_path ?? ""
    }
    
    public var parameters: APIParameters? {
        return cdy_parameters
    }
    
    public var method: APIMethod {
        return cdy_method ?? NetworkConfig.baseMethod
    }
    
    public var plugins: APIPlugins {
        return cdy_plugins
    }
    
    public var retry: APINumber {
        return cdy_retry
    }
    
    public var stubBehavior: APIStubBehavior {
        guard let _ = cdy_testJSON else {
            return .never
        }
        if cdy_testTime > 0 {
            return .delayed(seconds: cdy_testTime)
        } else {
            return .immediate
        }
    }
    
    public var sampleData: Data {
        if let json = cdy_testJSON {
            return json.data(using: String.Encoding.utf8)!
        }
        return "{\"Condy\":\"yangkj310@gmail.com\"}".data(using: String.Encoding.utf8)!
    }
}
