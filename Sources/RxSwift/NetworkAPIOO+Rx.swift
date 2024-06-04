//
//  NetworkAPIOO+Rx.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/12.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import RxSwift
import Moya

extension NetworkAPIOO {
    /// OOP Network request.
    /// Example:
    ///
    ///     let api = NetworkAPIOO.init()
    ///     api.ip = "https://www.httpbin.org"
    ///     api.path = "/ip"
    ///     api.method = APIMethod.get
    ///     api.plugins = [NetworkLoadingPlugin.init()]
    ///
    ///     api.request().asObservable()
    ///         .observe(on: MainScheduler.instance)
    ///         .subscribe { (data) in
    ///             print("\(data)")
    ///         } onError: { (error) in
    ///             print("Network failed: \(error.localizedDescription)")
    ///         }
    ///         .disposed(by: disposeBag)
    ///
    /// - Returns: Observable sequence JSON object. May be thrown twice.
    public func request() -> APIObservableJSON {
        apiTarget.request(callbackQueue: callbackQueue)
    }
}
