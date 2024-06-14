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
    ///     SharedAPI.userInfo(name: "yangKJ").request(successed: { response in
    ///         print(response.bmp.mappedJson)
    ///         // do somthing..
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
        
        Shared.shared.addedRequestingAPI(self, key: key, plugins: pls)
        
        let headstreamRequest = self.setupHeadstreamRequest(plugins: pls)
        if headstreamRequest.endRequest, let result = headstreamRequest.result {
            let outputResult = OutputResult(result: result, mapped2JSON: mapped2JSON)
            outputResult.mapResult(success: { json in
                Shared.shared.removeRequestingAPI(key)
                var response = outputResult.response
                response.bpm.mappedJson = json
                response.bpm.finished = true
                progress?(ProgressResponse(response: response))
                DispatchQueue.main.async { successed(response) }
            }, failure: { error in
                Shared.shared.removeRequestingAPI(key)
                DispatchQueue.main.async { failed(error) }
            })
            return nil
        }
        
        // 先抛出本地数据
        if mapped2JSON {
            if let json = try? headstreamRequest.toJSON(), var response = try? headstreamRequest.toResponse() {
                response.bpm.mappedJson = json
                response.bpm.finished = false
                DispatchQueue.main.async { successed(response) }
            }
        } else {
            if var response = try? headstreamRequest.toResponse() {
                response.bpm.mappedJson = response.data
                response.bpm.finished = false
                DispatchQueue.main.async { successed(response) }
            }
        }
        
        let provider = self.setupProvider(plugins: pls, session: headstreamRequest.session, queue: queue)
        
        // 共享网络插件处理
        if X.hasNetworkSharedPlugin(pls) {
            if let task = Shared.shared.readTask(key: key) {
                Shared.shared.cacheBlocks(key: key, successed: successed, failed: failed)
                return task
            }
            let task = self.request(provider, key: key, output: { outputResult in
                outputResult.mapResult(success: { json in
                    var response = outputResult.response
                    response.bpm.mappedJson = json
                    response.bpm.finished = true
                    progress?(ProgressResponse(response: response))
                    DispatchQueue.main.async {
                        Shared.shared.resultSuccessed(response, key: key)
                    }
                }, failure: { error in
                    DispatchQueue.main.async {
                        Shared.shared.resultFailed(error, key: key)
                    }
                })
            }, progress: progress)
            Shared.shared.cacheTask(key: key, task: task)
            Shared.shared.cacheBlocks(key: key, successed: successed, failed: failed)
            return task
        }
        
        // 最后处理网络数据
        return self.request(provider, key: key, output: { outputResult in
            outputResult.mapResult(success: { json in
                var response = outputResult.response
                response.bpm.mappedJson = json
                response.bpm.finished = true
                progress?(ProgressResponse(response: response))
                DispatchQueue.main.async { successed(response) }
            }, failure: { error in
                DispatchQueue.main.async { failed(error) }
            })
        }, progress: progress)
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
    
    private func setupEndpoint(plugins: APIPlugins) -> (MultiTarget) -> Endpoint {
        //let headers = session.sessionConfiguration.headers
        let endpointTask = X.hasNetworkFilesPluginTask(plugins) ?? self.task
        var endpointHeaders = X.hasNetworkHttpHeaderPlugin(plugins)
        if let dict = self.headers {
            // Merge the dictionaries and take the second value.
            endpointHeaders = endpointHeaders.merging(dict) { $1 }
        }
        return { _ in
            Endpoint(url: URL(target: self).absoluteString,
                     sampleResponseClosure: { self.sampleResponse },
                     method: self.method,
                     task: endpointTask,
                     httpHeaderFields: endpointHeaders)
        }
    }
    
    private func endpointResolver() -> MoyaProvider<MultiTarget>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = self.httpShouldHandleCookies
                request.timeoutInterval = BoomingSetup.timeoutIntervalForRequest
                closure(.success(request))
            } catch MoyaError.requestMapping(let url) {
                closure(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                closure(.failure(MoyaError.parameterEncoding(error)))
            } catch let error {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
    
    private func stubBehaviourClosure() -> (MultiTarget) -> Moya.StubBehavior {
        return { _ in
            self.stubBehavior
        }
    }
    
    private func setupProvider(plugins: APIPlugins, session: Moya.Session?, queue: DispatchQueue?) -> MoyaProvider<MultiTarget> {
        let safetyQueue = X.safetyQueue(queue)
        let session = session ?? {
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
                interceptor: X.hasAuthenticationPlugin(plugins)
            )
        }()
        return MoyaProvider<MultiTarget>.init(
            endpointClosure: setupEndpoint(plugins: plugins),
            requestClosure: endpointResolver(),
            stubClosure: stubBehaviourClosure(),
            callbackQueue: safetyQueue,
            session: session,
            plugins: plugins,
            trackInflights: false
        )
    }
    
    /// 最后的输出结果，插件配置处理
    private func setupOutputResult(provider: MoyaProvider<MultiTarget>, result: APIResponseResult, onNext: @escaping OutputResultBlock) {
        let plugins = provider.plugins.compactMap { $0 as? PluginSubType }
        var outputResult = OutputResult.init(result: result, mapped2JSON: mapped2JSON)
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
                         key: String,
                         output: @escaping (OutputResult) -> Void,
                         progress: ProgressBlock?) -> Moya.Cancellable {
        let target = MultiTarget.target(self)
        return provider.request(target, progress: progress, completion: { result in
            setupOutputResult(provider: provider, result: result) { outputResult in
                if outputResult.againRequest {
                    _ = request(provider, key: key, output: output, progress: progress)
                    return
                }
                Shared.shared.removeRequestingAPI(key)
                output(outputResult)
            }
        })
    }
}
