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
    
    private let plugins: APIPlugins
    
    public init(result: Result<Moya.Response, MoyaError>, plugins: APIPlugins) {
        self.result = result
        self.plugins = plugins
    }
}

extension LastNeverResult {
    
    func mapResult(success: APISuccess? = nil, failure: APIFailure? = nil, progress: ProgressBlock? = nil) {
        if let downloadURL = X.hasNetworkFilesPlugin(plugins) {
            switch result {
            case .success(let response):
                success?(downloadURL)
                progress?(ProgressResponse(response: response))
            case .failure(let error):
                failure?(error)
            }
            return
        }
        if let mapResult = mapResult {
            switch mapResult {
            case let .success(json):
                success?(json)
            case let .failure(error):
                failure?(error)
            }
            return
        }
        switch result {
        case let .success(response):
            do {
                let json = try RxNetworks.X.toJSON(with: response)
                self.mapResult = .success(json)
                success?(json)
                progress?(ProgressResponse(response: response))
            } catch MoyaError.statusCode(let response) {
                let error = MoyaError.statusCode(response)
                self.mapResult = .failure(error)
                failure?(error)
            } catch MoyaError.jsonMapping(let response) {
                let error = MoyaError.jsonMapping(response)
                self.mapResult = .failure(error)
                failure?(error)
            } catch {
                if let error = error as? MoyaError {
                    self.mapResult = .failure(error)
                }
                failure?(error)
            }
        case let .failure(error):
            self.mapResult = .failure(error)
            failure?(error)
        }
    }
}
