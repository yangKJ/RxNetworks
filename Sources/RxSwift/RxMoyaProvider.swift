//
//  RxMoyaProvider.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

///`Moya/RxSwift`文档
/// https://github.com/Moya/Moya/tree/master/Sources/RxMoya

@_exported import RxSwift
@_exported import Moya

extension MoyaProvider: ReactiveCompatible { }

public extension Reactive where Base: MoyaProvider<MultiTarget> {
    
    /// Designated request-making method.
    /// - Parameters:
    ///   - api: Request body
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Observable sequence JSON object. May be thrown twice.
    func request(api: NetworkAPI, callbackQueue: DispatchQueue? = nil, result: MoyaResult? = nil) -> APIObservableJSON {
        var single: APIObservableJSON = APIObservableJSON.create { (observer) in
            // First process local data
            if let result = result,
               let response = try? result.get(),
               let response = try? response.filterSuccessfulStatusCodes(),
               let jsonObject = try? response.mapJSON() {
                observer.onNext(jsonObject)
            }
            // And then process network data
            let token = self.beginRequest(api, queue: callbackQueue, successed: {
                observer.onNext($0)
                observer.onCompleted()
            }, failed: { error in
                observer.onError(error)
            })
            return Disposables.create {
                token.cancel()
            }
        }
        if api.retry > 0 {
            single = single.retry(api.retry) // Number of retries after failed.
        }
        return single.share(replay: 1, scope: .forever)
    }
    
    @discardableResult
    private func beginRequest(_ api: NetworkAPI,
                              queue: DispatchQueue?,
                              successed: @escaping (_ json: Any) -> Void,
                              failed: @escaping (_ error: Swift.Error) -> Void,
                              progress: ProgressBlock? = nil) -> Cancellable {
        let target = MultiTarget.target(api)
        let tempPlugins = base.plugins
        return base.request(target, callbackQueue: queue, progress: progress, completion: { result in
            var _result = result
            var _mapResult: MapJSONResult?
            if let plugins = tempPlugins as? [PluginSubType] {
                // last never handy data, last chance
                let tuple = NetworkUtil.handyLastNeverPlugin(plugins, result: _result, target: target)
                if tuple.againRequest == true {
                    beginRequest(api, queue: queue, successed: successed, failed: failed, progress: progress)
                    return
                }
                _result = tuple.result
                _mapResult = tuple.mapResult
            }
            
            if let _mapResult = _mapResult {
                switch _mapResult {
                case let .success(json):
                    successed(json)
                case let .failure(error):
                    failed(error)
                }
            } else {
                switch _result {
                case let .success(response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let json = try response.mapJSON()
                        successed(json)
                    } catch MoyaError.statusCode(let response) {
                        failed(MoyaError.statusCode(response))
                    } catch MoyaError.jsonMapping(let response) {
                        failed(MoyaError.jsonMapping(response))
                    } catch {
                        failed(error)
                    }
                case let .failure(error):
                    failed(error)
                }
            }
        })
    }
}
