//
//  LastNeverResult.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/30.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public typealias LastNeverCallback = ((_ lastResult: OutputResult) -> Void)

@available(*, deprecated, message: "Typo. Use `OutputResult` instead", renamed: "OutputResult")
public typealias LastNeverResult = OutputResult

/// Containing the data source and whether auto last network request.
public final class OutputResult {
    
    public var result: APIResponseResult
    
    /// 解决重复解析问题，如果某款插件已经对数据进行解析成Any之后
    /// Solve the problem of repeated parsing, if a plugin has parsed the data into `Any`
    public var mapSuccessedResult: Any?
    
    /// 是否自动上次网络请求
    public var againRequest: Bool = false
    
    public init(result: APIResponseResult) {
        self.result = result
    }
}

extension OutputResult {
    
    public func mapResult(success: APISuccess? = nil,
                          failure: APIFailure? = nil,
                          progress: ProgressBlock? = nil,
                          setToMapSuccessedResult: Bool = true) {
        if let mapResult = mapSuccessedResult {
            success?(mapResult)
            return
        }
        switch result {
        case let .success(response):
            do {
                let json = try X.toJSON(with: response)
                if setToMapSuccessedResult {
                    self.mapSuccessedResult = json
                }
                success?(json)
                progress?(ProgressResponse(response: response))
            } catch MoyaError.statusCode(let response) {
                let error = MoyaError.statusCode(response)
                failure?(error)
            } catch MoyaError.jsonMapping(let response) {
                let error = MoyaError.jsonMapping(response)
                failure?(error)
            } catch MoyaError.stringMapping(let response) {
                let error = MoyaError.stringMapping(response)
                failure?(error)
            } catch {
                failure?(MoyaError.underlying(error, nil))
            }
        case let .failure(error):
            failure?(error)
        }
    }
}
