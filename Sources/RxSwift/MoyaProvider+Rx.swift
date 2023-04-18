//
//  RxMoyaProvider.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

///`Moya/RxSwift`文档
/// https://github.com/Moya/Moya/tree/master/Sources/RxMoya

@_exported import RxSwift
import Moya

extension MoyaProvider: ReactiveCompatible { }

extension Reactive where Base: MoyaProvider<MultiTarget> {
    
    /// Designated request-making method.
    /// - Parameters:
    ///   - api: Request body
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Observable sequence JSON object. May be thrown twice.
    public func request(api: NetworkAPI, callbackQueue: DispatchQueue? = nil, result: MoyaResult? = nil) -> APIObservableJSON {
        var single: APIObservableJSON = APIObservableJSON.create { (observer) in
            // First process local data
            if let result = result,
               let response = try? result.get(),
               let response = try? response.filterSuccessfulStatusCodes(),
               let jsonobjc = try? response.mapJSON() {
                observer.onNext(jsonobjc)
            }
            // And then process network data
            let token = NetworkUtil.beginRequest(api, base: base, queue: callbackQueue, success: {
                observer.onNext($0)
                observer.onCompleted()
            }, failure: { error in
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
}
