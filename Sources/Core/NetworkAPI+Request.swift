//
//  NetworkAPI+Request.swift
//  RxNetworks
//
//  Created by Condy on 2022/6/10.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya
import CommonCrypto

/// 如果未使用`rx`也可以直接使用该方法
extension NetworkAPI {
    /// 标识前缀，MD5
    var keyPrefix: String {
        let paramString = X.sortParametersToString(parameters)
        let string = ip + path + "\(paramString)"
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
    
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
        let key = self.keyPrefix
        let plugins__ = RxNetworks.X.setupPluginsAndKey(key, plugins: plugins)
        
        SharedDriver.shared.addedRequestingAPI(self, key: key, plugins: plugins__)
        
        let request = self.setupConfiguration(plugins: plugins__)
        if request.endRequest, let result = request.result {
            let lastResult = LastNeverResult(result: result, plugins: plugins__)
            lastResult.mapResult(success: { json in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { success(json) }
            }, failure: { error in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { failure(error) }
            }, progress: progress)
            return nil
        }
        
        let session = request.session ?? {
            let configuration = URLSessionConfiguration.af.default
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
        if let json = try? request.toJSON() {
            DispatchQueue.main.async { success(json) }
        }
        
        // 共享网络插件处理
        if RxNetworks.X.hasNetworkSharedPlugin(plugins__) {
            if let task = SharedDriver.shared.readTask(key: key) {
                SharedDriver.shared.cacheBlocks(key: key, success: success, failure: failure)
                return task
            }
            let task = self.request(plugins__, provider: provider, success: { json in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async {
                    SharedDriver.shared.result(.success(json), key: key)
                }
            }, failure: { error in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async {
                    SharedDriver.shared.result(.failure(error), key: key)
                }
            }, progress: progress)
            SharedDriver.shared.cacheTask(key: key, task: task)
            SharedDriver.shared.cacheBlocks(key: key, success: success, failure: failure)
            return task
        }
        // 再处理网络数据
        return self.request(plugins__, provider: provider, success: { json in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { success(json) }
        }, failure: { error in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { failure(error) }
        }, progress: progress)
    }
}

extension NetworkAPI {
    
    /// 最开始配置插件信息
    private func setupConfiguration(plugins: APIPlugins) -> HeadstreamRequest {
        var request = HeadstreamRequest()
        plugins.forEach {
            request = $0.configuration(request, target: self)
        }
        return request
    }
    
    /// 最后的输出结果，插件配置处理
    private func setupOutputResult(plugins: APIPlugins, result: APIResponseResult, onNext: @escaping LastNeverCallback) {
        var lastResult = LastNeverResult.init(result: result, plugins: plugins)
        var iterator = plugins.makeIterator()
        func handleLastNever(_ plugin: RxNetworks.PluginSubType?) {
            guard let plugin = plugin else {
                onNext(lastResult)
                return
            }
            plugin.lastNever(lastResult, target: self) {
                lastResult = $0
                handleLastNever(iterator.next())
            }
        }
        handleLastNever(iterator.next())
    }
    
    @discardableResult private func request(_ plugins: APIPlugins,
                                            provider: MoyaProvider<MultiTarget>,
                                            success: @escaping APISuccess,
                                            failure: @escaping APIFailure,
                                            progress: ProgressBlock? = nil) -> Cancellable {
        let target = MultiTarget.target(self)
        return provider.request(target, progress: progress, completion: { result in
            setupOutputResult(plugins: plugins, result: result) { lastResult in
                if lastResult.againRequest {
                    request(plugins, provider: provider, success: success, failure: failure, progress: progress)
                    return
                }
                lastResult.mapResult(success: success, failure: failure)
            }
        })
    }
}
