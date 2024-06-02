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
    ///     GitHubAPI.userInfo(name: "yangKJ").HTTPRequest(success: { json in
    ///         print(json)
    ///         let model = Deserialized<Model>.toModel(with: json)
    ///     }, failure: { error in
    ///         print(error.localizedDescription)
    ///     })
    ///
    /// - Parameters:
    ///   - success: Success description, return in the main thread.
    ///   - failure: Failure description, return in the main thread.
    ///   - progress: Progress description
    ///   - queue: Callback queue. If nil - queue from provider initializer will be used.
    ///   - plugins: Set the plug-ins required for this request separately, eg: cache first page data.
    /// - Returns: a `Cancellable` token to cancel the request later.
    @discardableResult func HTTPRequest(
        success: @escaping APISuccess,
        failure: @escaping APIFailure,
        progress: ProgressBlock? = nil,
        queue: DispatchQueue? = nil,
        plugins: APIPlugins = []
    ) -> Moya.Cancellable? {
        let key = self.keyPrefix
        let pls = X.setupPluginsAndKey(key, plugins: self.plugins + plugins)
        
        SharedDriver.shared.addedRequestingAPI(self, key: key, plugins: pls)
        
        let request = self.setupHeadstreamRequest(plugins: pls)
        if request.endRequest, let result = request.result {
            let lastResult = OutputResult(result: result)
            lastResult.mapResult(success: { json in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { success(json) }
            }, failure: { error in
                SharedDriver.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { failure(error) }
            }, progress: progress)
            return nil
        }
        
        // 先抛出本地数据
        if let json = try? request.toJSON() {
            DispatchQueue.main.async { success(json) }
        }
        
        let safetyQueue = X.safetyQueue(queue)
        
        let session = request.session ?? {
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
        
        //let headers = session.sessionConfiguration.headers
        let endpointTask = X.hasNetworkFilesPluginTask(pls)
        var endpointHeaders = X.hasNetworkHttpHeaderPlugin(pls)
        if let dict = self.headers {
            // Merge the dictionaries and take the second value.
            endpointHeaders = endpointHeaders.merging(dict) { $1 }
        }
        
        let target = MultiTarget.target(self)
        let provider = MoyaProvider<MultiTarget>.init(endpointClosure: { _ in
            Endpoint(url: URL(target: target).absoluteString,
                     sampleResponseClosure: { .networkResponse(200, self.sampleData) },
                     method: self.method,
                     task: endpointTask ?? self.task,
                     httpHeaderFields: endpointHeaders)
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
                SharedDriver.shared.cacheBlocks(key: key, success: success, failure: failure)
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
            SharedDriver.shared.cacheBlocks(key: key, success: success, failure: failure)
            return task
        }
        // 再处理网络数据
        return self.request(provider, success: { json in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { success(json) }
        }, failure: { error in
            SharedDriver.shared.removeRequestingAPI(key)
            DispatchQueue.main.async { failure(error) }
        }, progress: progress)
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
        plugins.forEach {
            request = $0.configuration(request, target: self)
        }
        return request
    }
    
    /// 最后的输出结果，插件配置处理
    private func setupOutputResult(provider: MoyaProvider<MultiTarget>, result: APIResponseResult, onNext: @escaping LastNeverCallback) {
        let plugins = provider.plugins.compactMap { $0 as? PluginSubType }
        var outputResult = OutputResult(result: result)
        var iterator = plugins.makeIterator()
        func output(_ plugin: PluginSubType?) {
            guard let plugin = plugin else {
                onNext(outputResult)
                return
            }
            plugin.lastNever(outputResult, target: self) {
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
            setupOutputResult(provider: provider, result: result) { lastResult in
                if lastResult.againRequest {
                    _ = request(provider, success: success, failure: failure, progress: progress)
                    return
                }
                lastResult.mapResult(success: success, failure: failure)
            }
        })
    }
}
