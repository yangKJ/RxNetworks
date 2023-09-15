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
    public var result: Result<Moya.Response, MoyaError>?
    
    public var session: Moya.Session?
    
    /// 是否结束后序网络请求
    public var endRequest: Bool = false
    
    public init() { }
}
