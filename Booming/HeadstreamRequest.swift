//
//  HeadstreamRequest.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/30.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// Configuration information, which contains the data source and whether to end the subsequent network request.
public final class HeadstreamRequest {
    
    /// Empty data, convenient for subsequent plugin operations.
    public var result: APIResponseResult?
    
    public var session: Moya.Session?
    
    /// 是否结束后序网络请求
    public var endRequest: Bool = false
    
    public init() { }
}

extension HeadstreamRequest {
    
    func toJSON() throws -> APIResultValue {
        try X.toJSON(with: try toResponse())
    }
    
    func toResponse() throws -> Moya.Response {
        guard let result = result else {
            let userInfo = [
                NSLocalizedDescriptionKey: "The result is empty."
            ]
            let error = NSError(domain: "com.condy.rx.network", code: 2004, userInfo: userInfo)
            throw MoyaError.underlying(error, nil)
        }
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
