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
    public var mappedResult: APIJSONResult?
    
    /// 是否自动上次网络请求
    public var againRequest: Bool = false
    
    private let mapped2JSON: Bool
    
    public init(result: APIResponseResult, mapped2JSON: Bool) {
        self.result = result
        self.mapped2JSON = mapped2JSON
    }
}

extension OutputResult {
    
    public var response: Moya.Response {
        try! result.get()
    }
    
    /// 解析数据
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - setToResult: 是否需要设置到`mappedResult`
    public func mapResult(success: ((APIResultValue?) -> Void)?,
                          failure: APIFailure?,
                          setToMappedResult: Bool = true,
                          mapped2JSON: Bool = false) {
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
                if mustMapedToJSON(compulsion: mapped2JSON) {
                    let json = try response.bpm.toJSON()
                    if setToMappedResult {
                        self.mappedResult = .success(json)
                    }
                    success?(json)
                } else {
                    let response = try response.filterSuccessfulStatusCodes()
                    success?(response.data)
                }
            } catch {
                if let error = error as? MoyaError {
                    failure?(error)
                } else {
                    failure?(MoyaError.underlying(error, nil))
                }
            }
        case let .failure(error):
            failure?(error)
        }
    }
    
    private func mustMapedToJSON(compulsion: Bool) -> Bool {
        return compulsion || mapped2JSON
    }
}
