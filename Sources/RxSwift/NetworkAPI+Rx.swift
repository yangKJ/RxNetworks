//
//  NetworkAPI+Rx.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/12.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import RxSwift
import Moya

/// 追加订阅网络方案
/// Append the subscription network scheme.
extension NetworkAPI {
    
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
    public func request(callbackQueue: DispatchQueue? = nil) -> APIObservableJSON {
        var tempPlugins: APIPlugins = self.plugins
        NetworkUtil.defaultPlugin(&tempPlugins, api: self)
        
        let target = MultiTarget.target(self)
        
        let tuple = NetworkUtil.handyConfigurationPlugin(tempPlugins, target: target)
        if tuple.endRequest == true {
            return X.RxSwift.transformAPIObservableJSON(tuple.result)
        }
        
        var session: Moya.Session
        if let _session = tuple.session {
            session = _session
        } else {
            let configuration = URLSessionConfiguration.af.default
            configuration.headers = Alamofire.HTTPHeaders.default
            configuration.timeoutIntervalForRequest = NetworkConfig.timeoutIntervalForRequest
            session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        }
        
        // 自定义并行队列
        let queue = DispatchQueue(label: "condy.rx.network.queue", attributes: [.concurrent])
        let provider = MoyaProvider<MultiTarget>(stubClosure: { _ in
            return stubBehavior
        }, callbackQueue: queue, session: session, plugins: tempPlugins)
        
        return provider.rx.request(api: self, callbackQueue: callbackQueue, result: tuple.result)
    }
}
