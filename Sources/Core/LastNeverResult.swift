//
//  LastNeverResult.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/30.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public typealias LastNeverCallback = ((_ lastResult: LastNeverResult) -> Void)

/// Containing the data source and whether auto last network request.
public final class LastNeverResult {
    
    public var result: Result<Moya.Response, MoyaError>
    
    /// 解决重复解析问题，如果某款插件已经对数据进行解析成Any之后
    /// Solve the problem of repeated parsing, if a plugin has parsed the data into `Any`
    public var mapResult: Result<Any, MoyaError>?
    
    /// 是否自动上次网络请求
    public var againRequest: Bool = false
    
    public init(result: Result<Moya.Response, MoyaError>) {
        self.result = result
    }
}

extension LastNeverResult {
    func handy(success: @escaping APISuccess, failure: @escaping APIFailure, progress: ProgressBlock? = nil) {
        if let mapResult = mapResult {
            switch mapResult {
            case let .success(json):
                success(json)
            case let .failure(error):
                failure(error)
            }
        } else {
            switch result {
            case let .success(response):
                do {
                    let json = try X.toJSON(with: response)
                    success(json)
                    progress?(ProgressResponse(response: response))
                } catch MoyaError.statusCode(let response) {
                    failure(MoyaError.statusCode(response))
                } catch MoyaError.jsonMapping(let response) {
                    failure(MoyaError.jsonMapping(response))
                } catch {
                    failure(error)
                }
            case let .failure(error):
                failure(error)
            }
        }
    }
}
