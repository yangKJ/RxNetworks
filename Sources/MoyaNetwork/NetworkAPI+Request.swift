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
        var plugins_: APIPlugins = self.plugins
        NetworkUtil.defaultPlugin(&plugins_, api: self)
        
        let tuple = NetworkUtil.handyConfigurationPlugin(plugins_, target: MultiTarget.target(self))
        if tuple.endRequest == true, let result = tuple.result {
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON()
                    DispatchQueue.main.async { success(jsonObject) }
                    // 直接进度拉满
                    progress?(ProgressResponse(response: response))
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
        
        let session = tuple.session ?? {
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
        }, callbackQueue: queue, session: session, plugins: plugins_)
        
        // 先抛出本地数据
        switch tuple.result {
        case .success(let response) where (try? response.filterSuccessfulStatusCodes()) != nil:
            if let jsonobjc = try? response.mapJSON() {
                DispatchQueue.main.async { success(jsonobjc) }
            }
            break
        default:
            break
        }
        // 再处理网络数据
        return NetworkUtil.beginRequest(self, base: provider, queue: queue, success: { json in
            DispatchQueue.main.async { success(json) }
        }, failure: { error in
            DispatchQueue.main.async { failure(error) }
        }, progress: progress)
    }
}
