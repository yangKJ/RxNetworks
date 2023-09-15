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
    ///   - queue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: a `Cancellable` token to cancel the request later.
    @discardableResult public func HTTPRequest(success: @escaping APISuccess,
                                               failure: @escaping APIFailure,
                                               progress: ProgressBlock? = nil,
                                               queue: DispatchQueue? = nil) -> Cancellable? {
        var plugins__ = self.plugins
        RxNetworks.X.defaultPlugin(&plugins__, api: self)
        
        plugins__ = RxNetworks.X.handyPlugins(plugins__)
        
        let target = MultiTarget.target(self)
        
        let request = RxNetworks.X.handyConfigurationPlugin(plugins__, target: target)
        if request.endRequest, let result = request.result {
            let lastResult = LastNeverResult(result: result)
            lastResult.handy(success: { json in
                DispatchQueue.main.async { success(json) }
            }, failure: { error in
                DispatchQueue.main.async { failure(error) }
            }, progress: progress)
            return nil
        }
        
        let session = request.session ?? {
            let configuration = URLSessionConfiguration.af.default
            configuration.headers = Alamofire.HTTPHeaders.default
            configuration.timeoutIntervalForRequest = NetworkConfig.timeoutIntervalForRequest
            return Moya.Session(configuration: configuration, startRequestsImmediately: false)
        }()
        
        let queue = queue ?? {
            // 自定义并行队列
            DispatchQueue(label: "condy.request.network.queue", attributes: [.concurrent])
        }()
        let provider = MoyaProvider<MultiTarget>(stubClosure: { _ in
            return stubBehavior
        }, callbackQueue: queue, session: session, plugins: plugins__)
        
        // 先抛出本地数据
        if case .success(let response) = request.result, let json = try? X.toJSON(with: response) {
            DispatchQueue.main.async { success(json) }
        }
        
        // 共享网络插件处理
        if RxNetworks.X.hasNetworkSharedPlugin(plugins__) {
            let key = SharedNetworked.shared.requestLink(with: target)
            if let task = SharedNetworked.shared.readTask(key: key) {
                SharedNetworked.shared.cacheBlocks(key: key, success: success, failure: failure)
                return task
            }
            let task = RxNetworks.X.request(target: target, provider: provider, queue: queue, success: { json in
                DispatchQueue.main.async {
                    SharedNetworked.shared.result(.success(json), key: key)
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    SharedNetworked.shared.result(.failure(error), key: key)
                }
            }, progress: progress)
            SharedNetworked.shared.cacheTask(key: key, task: task)
            SharedNetworked.shared.cacheBlocks(key: key, success: success, failure: failure)
            return task
        }
        // 再处理网络数据
        return RxNetworks.X.request(target: target, provider: provider, queue: queue, success: { json in
            DispatchQueue.main.async { success(json) }
        }, failure: { error in
            DispatchQueue.main.async { failure(error) }
        }, progress: progress)
    }
}
