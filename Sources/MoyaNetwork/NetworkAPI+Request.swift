//
//  NetworkAPI+Request.swift
//  RxNetworks
//
//  Created by Condy on 2022/6/10.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya

/// 如果未使用`rx`也可以直接使用该方法
extension NetworkAPI {
    
    /// Network request
    /// Example:
    ///
    ///     GitHubAPI.userInfo(name: "yangKJ").HTTPRequest(success: { json in
    ///         print(json)
    ///     }, failure: { error in
    ///         print(error.localizedDescription)
    ///     })
    ///
    /// - Parameters:
    ///   - success: Success description, return in the main thread.
    ///   - failure: Failure description, return in the main thread.
    ///   - progress: Progress description
    /// - Returns: a `Cancellable` token to cancel the request later.
    @discardableResult
    public func HTTPRequest(success: @escaping APISuccess,
                            failure: @escaping APIFailure,
                            progress: ProgressBlock? = nil) -> Cancellable? {
        var tempPlugins: APIPlugins = self.plugins
        NetworkUtil.defaultPlugin(&tempPlugins, api: self)
        
        let target = MultiTarget.target(self)
        
        let tuple = NetworkUtil.handyConfigurationPlugin(tempPlugins, target: target)
        if tuple.endRequest == true, let result = tuple.result {
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON()
                    DispatchQueue.main.async { success(jsonObject) }
                } catch MoyaError.jsonMapping(let response) {
                    DispatchQueue.main.async { failure(MoyaError.jsonMapping(response)) }
                } catch MoyaError.statusCode(let response) {
                    DispatchQueue.main.async { failure(MoyaError.statusCode(response)) }
                } catch {
                    DispatchQueue.main.async { failure(error) }
                }
            case let .failure(error):
                DispatchQueue.main.async { failure(error) }
            }
            return nil
        }
        
        var session: Moya.Session
        if let _session = tuple.session {
            session = _session
        } else {
            let configuration = URLSessionConfiguration.af.default
            configuration.headers = Alamofire.HTTPHeaders.default
            configuration.timeoutIntervalForRequest = NetworkConfig.timeoutIntervalForRequest
            session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        }
        
        // 自定义后台运行级别并行队列
        let queue = DispatchQueue(label: "condy.request.network.queue", qos: .background, attributes: [.concurrent])
        let provider = MoyaProvider<MultiTarget>(stubClosure: { _ in
            return stubBehavior
        }, callbackQueue: queue, session: session, plugins: tempPlugins)
        
        // 先抛出本地数据
        if let result = tuple.result,
           let response = try? result.get(),
           let response = try? response.filterSuccessfulStatusCodes(),
           let jsonobjc = try? response.mapJSON() {
            DispatchQueue.main.async { success(jsonobjc) }
        }
        // 再处理网络数据
        return NetworkUtil.beginRequest(self, base: provider, queue: queue, success: { json in
            DispatchQueue.main.async { success(json) }
        }, failure: { error in
            DispatchQueue.main.async { failure(error) }
        }, progress: progress)
    }
}
