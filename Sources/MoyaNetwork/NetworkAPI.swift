//
//  NetworkAPI.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import RxSwift
import Moya

public protocol NetworkAPI: Moya.TargetType {
    
    /// Request host
    var ip: APIHost { get }
    /// Request parameters
    var parameters: APIParameters? { get }
    /// Plugin array
    var plugins: APIPlugins { get }
    /// Whether to go test data
    var stubBehavior: APIStubBehavior { get }
    /// Failed retry count, the default is zero
    var retry: APINumber { get }
    
    /// Network request.
    /// Protocol oriented network request, Indicator plugin are added by default
    /// Example:
    ///
    ///     func request(_ count: Int) -> Driver<[CacheModel]> {
    ///         CacheAPI.cache(count).request()
    ///                 .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
    ///                 .compactMap { $0.data }
    ///                 .observe(on: MainScheduler.instance) // The result is returned on the main thread
    ///                 .delay(.seconds(1), scheduler: MainScheduler.instance) // Delay 1 second to return
    ///                 .asDriver(onErrorJustReturn: []) // return null at the moment of error
    ///     }
    ///
    /// - Returns: Single sequence JSON object.
    func request() -> APIObservableJSON
    
    /// Network request.
    /// - Parameter callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single sequence JSON object.
    func request(callbackQueue: DispatchQueue?) -> APIObservableJSON
}
