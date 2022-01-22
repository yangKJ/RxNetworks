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
    /// - Returns: Single sequence JSON object.
    func request(api: NetworkAPI, callbackQueue: DispatchQueue? = nil, result: MoyaResult? = nil) -> APIObservableJSON {
        var single: APIObservableJSON = APIObservableJSON.create { (observer) in
            // First process local data
            if let result = result,
               let response = try? result.get(),
               let response = try? response.filterSuccessfulStatusCodes(),
               let jsonObject = try? response.mapJSON() {
                observer.onNext(jsonObject)
            }
            // And process network data
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
        return single//.distinctUntilChanged()
    }
    
    @discardableResult
    private func beginRequest(_ api: NetworkAPI,
                              queue: DispatchQueue?,
                              successed: @escaping (_ json: Any) -> Void,
                              failed: @escaping (_ error: Swift.Error) -> Void,
                              progress: ProgressBlock? = nil) -> Cancellable {
        let target = MultiTarget.target(api)
        let tempPlugins = base.plugins as! [PluginSubType]
        return base.request(target, callbackQueue: queue, progress: progress, completion: { result in
            // last never handy data, last chance
            let tuple = NetworkUtil.handyLastNeverPlugin(tempPlugins, result: result, target: target)
            if tuple.againRequest == true {
                beginRequest(api, queue: queue, successed: successed, failed: failed)
                return
            }
            
            switch tuple.result {
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
        })
    }
}
