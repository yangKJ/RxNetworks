//
//  NetworkTokenPlugin.swift
//  Booming
//
//  Created by Condy on 2024/6/6.
//

import Foundation
import Moya

/// 注入Token验证插件
public final class NetworkTokenPlugin {
    
    private var hasTokenBlock: ((String) -> Void)?
    
    public var options: NetworkTokenPlugin.Options
    
    public init(options: NetworkTokenPlugin.Options) {
        self.options = options
    }
}

extension NetworkTokenPlugin {
    public struct Options {
        public typealias ReacquireTokenBlock = (@escaping (String) -> Void) -> Void
        /// If the token fails, go back to get the new token.
        let reacquireTokenBlock: ReacquireTokenBlock
        /// Start preparing to set up token to header field.
        let prepareTokenBlock: () -> [String : String]
        /// Token failure conditions, The default error code is equal to 401.
        var tokenInvalidBlock: (MoyaError?, Moya.Response?) -> Bool = NetworkTokenPlugin.defaultTokenInvalid()
        
        /// You only need to unify the unauthorized status of 401.
        public var tokenInvalidCode: Int = BoomingSetup.tokenInvalidCode
        
        public init(addToken: @escaping () -> [String:String], reacquireToken: @escaping ReacquireTokenBlock) {
            self.reacquireTokenBlock = reacquireToken
            self.prepareTokenBlock = addToken
        }
        
        /// Token failure conditions, The default error code is equal to 401.
        /// - Parameter block: Token invalidation condition callback.
        public mutating func setTokenInvalidBlock(block: @escaping (MoyaError?, Moya.Response?) -> Bool) {
            self.tokenInvalidBlock = block
        }
    }
}

extension NetworkTokenPlugin: PluginSubType {
    
    public var pluginName: String {
        "TokenAuthorization"
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        let fields = self.options.prepareTokenBlock()
        guard !fields.isEmpty else {
            return request
        }
        var request = request
        for (key, value) in fields where !value.isEmpty {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
    
    public func outputResult(_ result: OutputResult, target: TargetType, onNext: @escaping OutputResultBlock) {
        self.hasTokenBlock = { [weak self] (token_: String) -> Void in
            if !token_.isEmpty {
                result.againRequest = true
            } else {
                let code = self?.options.tokenInvalidCode ?? BoomingSetup.tokenInvalidCode
                let response = Moya.Response(statusCode: code, data: Data())
                result.result = .failure(.statusCode(response))
                result.againRequest = false
            }
            onNext(result)
        }
        switch result.result {
        case .success(let response):
            if !self.options.tokenInvalidBlock(nil, response) {
                return onNext(result)
            }
        case .failure(let error):
            if !self.options.tokenInvalidBlock(error, nil) {
                return onNext(result)
            }
        }
        let blcok = { [weak self] (token_: String) -> Void in
            self?.hasTokenBlock?(token_)
        }
        self.options.reacquireTokenBlock(blcok)
    }
}

extension NetworkTokenPlugin {
    /// Default judgement token is invalid.
    public final class func defaultTokenInvalid() -> (MoyaError?, Moya.Response?) -> Bool {
        return { error, response in
            if let response = response, response.statusCode == BoomingSetup.tokenInvalidCode {
                return true
            }
            if let error = error {
                return error.errorCode == BoomingSetup.tokenInvalidCode
            }
            return false
        }
    }
}
