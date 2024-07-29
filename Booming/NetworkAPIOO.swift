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
    public var ip: APIHost = BoomingSetup.baseURL
    /// Request path
    public var path: APIPath?
    /// Request parameters
    public var parameters: APIParameters?
    /// Request type
    public var method: APIMethod = BoomingSetup.baseMethod
    /// Plugin array
    public var plugins: APIPlugins = []
    /// Failed retry count
    public var retry: APINumber = 0
    /// Callback queue. If nil - queue from provider initializer will be used.
    public var callbackQueue: DispatchQueue?
    /// Default true.
    public var httpShouldHandleCookies: Bool = true
    /// Mapped to json, Default is true.
    public var mapped2JSON: Bool = BoomingSetup.mapped2JSON
    
    // MARK: - test
    
    /// Test data, after setting the value of this property, only the test data is taken
    public var testData: Data?
    /// Test data return time, the default is half a second
    public var testTime: Double = 0.5
    
    public init() { }
    
    @discardableResult
    open func request(successed: @escaping APISuccessed, failed: APIFailure? = nil) -> Moya.Cancellable? {
        return apiTarget.request(successed: successed, failed: { error in
            failed?(error)
        }, queue: callbackQueue)
    }
    
    public var apiTarget: NetworkAPI {
        NetworkCompatible_.init(target: self)
    }
}

private struct NetworkCompatible_: NetworkAPI {
    
    let target: NetworkAPIOO
    
    init(target: NetworkAPIOO) {
        self.target = target
    }
    
    var ip: APIHost {
        return target.ip
    }
    
    var path: String {
        return target.path ?? ""
    }
    
    var parameters: APIParameters? {
        return target.parameters
    }
    
    var method: APIMethod {
        return target.method
    }
    
    var plugins: APIPlugins {
        return target.plugins
    }
    
    var retry: APINumber {
        return target.retry
    }
    
    var httpShouldHandleCookies: Bool {
        target.httpShouldHandleCookies
    }
    
    var mapped2JSON: Bool {
        target.mapped2JSON
    }
    
    var stubBehavior: APIStubBehavior {
        guard let _ = target.testData else {
            return .never
        }
        if target.testTime > 0 {
            return .delayed(seconds: target.testTime)
        } else {
            return .immediate
        }
    }
    
    var sampleData: Data {
        return target.testData ?? {
            "{\"Condy\":\"yangkj310@gmail.com\"}".data(using: String.Encoding.utf8)!
        }()
    }
}
