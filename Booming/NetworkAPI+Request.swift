//
//  NetworkAPI+Request.swift
//  RxNetworks
//
//  Created by Condy on 2022/6/10.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya

public extension NetworkAPI {
    /// Network request
    /// Example:
    ///
    ///     GitHubAPI.userInfo(name: "yangKJ").request(successed: { json, finished in
    ///         print(json)
    ///         let model = Deserialized<Model>.toModel(with: json)
    ///     }, failed: { error in
    ///         print(error.localizedDescription)
    ///     })
    ///
    /// - Parameters:
    ///   - successed: Success description, return in the main thread.
    ///   - failed: Failure description, return in the main thread.
    ///   - progress: Progress description.
    ///   - queue: Callback queue. If nil - queue from provider initializer will be used.
    ///   - plugins: Set the plug-ins required for this request separately, eg: cache first page data.
    /// - Returns: a `Cancellable` token to cancel the request later.
    @discardableResult func request(
        successed: @escaping APISuccessed,
        failed: @escaping APIFailure,
        progress: ProgressBlock? = nil,
        queue: DispatchQueue? = nil,
        plugins: APIPlugins = []
    ) -> Moya.Cancellable? {
        let key = self.keyPrefix
        let pls = X.setupPluginsAndKey(key, plugins: self.plugins + plugins)
        
        SharedDriver.shared.addedRequestingAPI(self, key: key, plugins: pls)
        
        let headstreamRequest = self.setupHeadstreamRequest(plugins: pls)
        if headstreamRequest.endRequest, let result = headstreamRequest.result {
            let lastResult = OutputResult(result: result)
            lastResult.mapResult(success: { json in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { successed(json, true) }
            }, failure: { error in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { failed(error) }
            }, progress: progress)
            return nil
        }
        
        // 先抛出本地数据
        if let json = try? headstreamRequest.toJSON() {
            DispatchQueue.main.async { successed(json, false) }
        }
        
        let safetyQueue = X.safetyQueue(queue)
        
        let session = headstreamRequest.session ?? {
            let configuration: URLSessionConfiguration
            if BoomingSetup.supportBackgroundRequest {
                configuration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
            } else {
                configuration = URLSessionConfiguration.default
            }
            configuration.headers = Alamofire.HTTPHeaders.default
            configuration.timeoutIntervalForRequest = BoomingSetup.timeoutIntervalForRequest
            return Moya.Session(
                configuration: configuration,
                rootQueue: safetyQueue,
                startRequestsImmediately: BoomingSetup.startRequestsImmediately,
                interceptor: X.hasAuthenticationPlugin(pls)
            )
        }()
        
        let provider = MoyaProvider<MultiTarget>.init(endpointClosure: { _ in
            setupEndpoint(plugins: pls)
        }, requestClosure: { endpoint, block in
            do {
                let urlRequest = try endpoint.urlRequest()
                block(.success(urlRequest))
            } catch MoyaError.requestMapping(let url) {
                block(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                block(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                block(.failure(MoyaError.underlying(error, nil)))
            }
        }, stubClosure: { _ in
            stubBehavior
        }, callbackQueue: safetyQueue, session: session, plugins: pls)
        
        // 共享网络插件处理
        if X.hasNetworkSharedPlugin(pls) {
            if let task = SharedDriver.shared.readTask(key: key) {
                SharedDriver.shared.cacheBlocks(key: key, successed: successed, failed: failed)
                return task
            }
            let task = self.request(provider, success: { json in
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
            SharedDriver.shared.cacheBlocks(key: key, successed: successed, failed: failed)
            return task
        }
        // 再处理网络数据
        return self.request(provider, success: { json in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { successed(json, true) }
        }, failure: { error in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { failed(error) }
        }, progress: progress)
    }
    
    @discardableResult func HTTPRequest(
        success: @escaping APISuccess,
        failure: @escaping APIFailure,
        progress: ProgressBlock? = nil,
        queue: DispatchQueue? = nil,
        plugins: APIPlugins = []
    ) -> Moya.Cancellable? {
        request(successed: { json, _ in
            success(json)
        }, failed: failure, progress: progress, queue: queue, plugins: plugins)
    }
    
    @discardableResult
    func request(plugins: APIPlugins = [], complete: @escaping APIComplete) -> Moya.Cancellable? {
        HTTPRequest(success: { json in
            complete(.success(json))
        }, failure: { error in
            complete(.failure(error))
        }, plugins: plugins)
    }
}

// MARK: - private methods
extension NetworkAPI {
    /// 最开始配置插件信息
    private func setupHeadstreamRequest(plugins: APIPlugins) -> HeadstreamRequest {
        var request = HeadstreamRequest()
        let target = MultiTarget.target(self)
        plugins.forEach {
            request = $0.configuration(request, target: target)
        }
        return request
    }
    
    private func setupEndpoint(plugins: APIPlugins) -> Moya.Endpoint {
        //let headers = session.sessionConfiguration.headers
        let endpointTask = X.hasNetworkFilesPluginTask(plugins) ?? self.task
        var endpointHeaders = X.hasNetworkHttpHeaderPlugin(plugins)
        if let dict = self.headers {
            // Merge the dictionaries and take the second value.
            endpointHeaders = endpointHeaders.merging(dict) { $1 }
        }
        return Endpoint(url: URL(target: self).absoluteString,
                        sampleResponseClosure: { .networkResponse(200, self.sampleData) },
                        method: self.method,
                        task: endpointTask,
                        httpHeaderFields: endpointHeaders)
    }
    
    /// 最后的输出结果，插件配置处理
    private func setupOutputResult(provider: MoyaProvider<MultiTarget>, result: APIResponseResult, onNext: @escaping OutputResultBlock) {
        let plugins = provider.plugins.compactMap { $0 as? PluginSubType }
        var outputResult = OutputResult(result: result)
        let target = MultiTarget.target(self)
        var iterator = plugins.makeIterator()
        func output(_ plugin: PluginSubType?) {
            guard let plugin = plugin else {
                onNext(outputResult)
                return
            }
            plugin.outputResult(outputResult, target: target) {
                outputResult = $0
                output(iterator.next())
            }
        }
        output(iterator.next())
    }
    
    private func request(_ provider: MoyaProvider<MultiTarget>,
                         success: @escaping APISuccess,
                         failure: @escaping APIFailure,
                         progress: ProgressBlock? = nil) -> Moya.Cancellable {
        let target = MultiTarget.target(self)
        return provider.request(target, progress: progress, completion: { result in
            setupOutputResult(provider: provider, result: result) { outputResult in
                if outputResult.againRequest {
                    _ = request(provider, success: success, failure: failure, progress: progress)
                    return
                }
                outputResult.mapResult(success: success, failure: failure)
            }
        })
    }
}
