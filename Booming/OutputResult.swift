//
//  LastNeverResult.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/30.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public typealias OutputResultBlock = ((_ lastResult: OutputResult) -> Void)

/// Containing the data source and whether auto last network request.
public final class OutputResult {
    
    public var result: APIResponseResult
    
    /// 解决重复解析问题，如果某款插件已经解析过数据。
    /// If a plug-in has mapped the data, and then save it.
    public var mappedResult: Result<Any, MoyaError>?
    
    /// 是否自动上次网络请求
    public var againRequest: Bool = false
    
    public init(result: APIResponseResult) {
        self.result = result
    }
}

extension OutputResult {
    
    public var response: Moya.Response? {
        try? result.get()
    }
    
    /// 解析数据
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - setToResult: 是否需要设置到`mappedResult`
    public func mapResult(success: APISuccess?, failure: APIFailure?, setToResult: Bool = true) {
        if let mapResult = mappedResult {
            switch mapResult {
            case .success(let res):
                success?(res)
            case .failure(let error):
                failure?(error)
            }
            return
        }
        switch result {
        case let .success(response):
            do {
                let json = try X.toJSON(with: response)
                if setToResult {
                    self.mappedResult = .success(json)
                }
                success?(json)
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

@available(*, deprecated, message: "Typo. Use `OutputResultBlock` instead", renamed: "OutputResultBlock")
public typealias LastNeverCallback = OutputResultBlock

@available(*, deprecated, message: "Typo. Use `OutputResult` instead", renamed: "OutputResult")
public typealias LastNeverResult = OutputResult
