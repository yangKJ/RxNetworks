//
//  NetworkAPI+Rx.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/12.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya
@_exported import Booming
@_exported import RxSwift
//#if canImport(Plugins)
//@_exported import Plugins
//#endif

public typealias APIObservableJSON = RxSwift.Observable<Any>

/// 追加订阅网络方案
/// Append the subscription network scheme.
public extension NetworkAPI {
    /// Network request.
    /// Protocol oriented network request, Indicator plugin are added by default
    /// Example:
    ///
    ///     func request(_ count: Int) -> Driver<[CacheModel]> {
    ///         CacheAPI.cache(count).request()
    ///             .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
    ///             .compactMap { $0.data }
    ///             .observe(on: MainScheduler.instance) // The result is returned on the main thread
    ///             .delay(.seconds(1), scheduler: MainScheduler.instance) // Delay 1 second to return
    ///             .asDriver(onErrorJustReturn: []) // return null at the moment of error
    ///     }
    ///
    /// - Parameter callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Observable sequence JSON object. May be thrown twice.
    func request(
        callbackQueue: DispatchQueue? = nil,
        plugins: APIPlugins = []
    ) -> APIObservableJSON {
        var single = APIObservableJSON.create { observer in
            let token = HTTPRequest(success: { json in
                observer.onNext(json)
                observer.onCompleted()
            }, failure: { error in
                observer.onError(error)
            }, queue: callbackQueue, plugins: plugins)
            return Disposables.create {
                token?.cancel()
            }
        }
        if self.retry > 0 {
            single = single.retry(self.retry) // Number of retries after failed.
        }
        return single.share(replay: 1, scope: .forever)
    }
}
