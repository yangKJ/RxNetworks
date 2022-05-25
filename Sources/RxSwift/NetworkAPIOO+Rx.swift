//
//  NetworkAPIOO+Rx.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/12.
//

import Foundation
import RxSwift
import Moya

extension NetworkAPIOO {
    /// OOP Network request.
    /// Example:
    ///
    ///     var api = NetworkAPIOO.init()
    ///     api.cdy_ip = "https://www.httpbin.org"
    ///     api.cdy_path = "/ip"
    ///     api.cdy_method = APIMethod.get
    ///     api.cdy_plugins = [NetworkLoadingPlugin.init()]
    ///     api.cdy_testJSON = "{\"Condy\":\"ykj310@126.com\"}"
    ///
    ///     api.cdy_HTTPRequest()
    ///         .asObservable()
    ///         .observe(on: MainScheduler.instance)
    ///         .subscribe { (data) in
    ///             print("\(data)")
    ///         } onError: { (error) in
    ///             print("Network failed: \(error.localizedDescription)")
    ///         }
    ///         .disposed(by: disposeBag)
    ///
    /// - Parameter callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Observable sequence JSON object. May be thrown twice.
    public func cdy_HTTPRequest(_ callbackQueue: DispatchQueue? = nil) -> APIObservableJSON {
        var api = RxNetworks.NetworkObjectAPI.init()
        api.cdy_ip = cdy_ip
        api.cdy_path = cdy_path
        api.cdy_parameters = cdy_parameters
        api.cdy_method = cdy_method
        api.cdy_plugins = cdy_plugins
        api.cdy_retry = cdy_retry
        if let json = cdy_testJSON {
            api.cdy_test = json
            if cdy_testTime > 0 {
                api.cdy_stubBehavior = StubBehavior.delayed(seconds: cdy_testTime)
            } else {
                api.cdy_stubBehavior = StubBehavior.immediate
            }
        } else {
            api.cdy_stubBehavior = StubBehavior.never
        }
        return api.request(callbackQueue: callbackQueue)
    }
}
