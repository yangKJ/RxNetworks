//
//  NetworkAPI+Request5.5.swift
//  Booming
//
//  Created by Condy on 2024/6/13.
//

import Foundation
import Alamofire
import Moya

#if swift(>=5.5)

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias Task = _Concurrency.Task

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NetworkAPI {
    
    /// Async network request.
    /// - Parameters:
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    ///   - plugins: Set the plug-ins required for this request separately, eg: cache first page data.
    /// - Returns: Return a response, has `mappedJson` and `finished` paramers.
    public func requestAsync(callbackQueue: DispatchQueue? = nil, plugins: APIPlugins = []) async throws -> Moya.Response {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Moya.Response, Swift.Error>) in
            request(successed: { response in
                continuation.resume(returning: response)
            }, failed: { error in
                continuation.resume(throwing: error)
            }, queue: callbackQueue, plugins: plugins)
        })
    }
}

#endif
