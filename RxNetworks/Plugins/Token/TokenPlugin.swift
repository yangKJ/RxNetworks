//
//  TokenPlugin.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/5/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxSwift
import RxCocoa

public final class TokenPlugin {
    
    public static let shared = TokenPlugin()
    
    public let hasToken: PublishRelay<String> = PublishRelay()
    public let repLogin: PublishRelay<Void> = PublishRelay()
    
    @UserDefault("condy_token", defaultValue: "")
    private(set) var token: String
    
    fileprivate let lock = NSLock()
    
    private init() {
        // You need to get the token again, 需要重新获取token的监听!
        let _ = repLogin.flatMapLatest(getToken).bind(to: self.hasToken)
        
        let _ = self.hasToken.subscribe(onNext: { [weak self] token_ in
            print("token: - " + token_)
            self?.setToken(token: token_)
        })
    }
    
    private func setToken(token: String) {
        lock.lock()
        defer { lock.unlock() }
        self.token = token
    }
    
    private func getToken() -> Observable<String> {
        if !token.isEmpty {
            return Observable<String>.just(token)
        } else {
            print("--------[开始登陆]--------")
            // 模拟获取token
            return Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
                .take(1)
                .do(onNext: { _ in
                    print("--------[登陆成功]--------")
                })
                .map({ _ in "\(arc4random())" })
        }
    }
}

extension TokenPlugin: PluginSubType {
    
    public var pluginName: String {
        "TokenPlugin"
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard !token.isEmpty else {
            return request
        }
        var request = request
        request.addValue("Token: " + token, forHTTPHeaderField: "Authorization")
        return request
    }
    
    public func lastNever(_ tuple: LastNeverTuple, target: TargetType, onNext: @escaping LastNeverCallback) {
        #if DEBUG
        guard self.token.isEmpty else {
            onNext(tuple)
            return
        }
        #else
        switch tuple.result {
        case .success:
            return onNext(tuple)
        case .failure(let error):
            guard error.errorCode == 401 else {
                onNext(tuple)
                return
            }
        }
        #endif
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let _ = self.hasToken.subscribe(onNext: { token_ in
            var __tuple = tuple
            if !token_.isEmpty {
                // 登陆成功后, 只需要重新请求接口，所以不需要response
                __tuple.againRequest = true
            } else {
                // 登陆失败后, 只需要统一401未授权状态即可，所以不需要data
                let response = Moya.Response(statusCode: 401, data: Data())
                __tuple.result = .failure(.statusCode(response))
                __tuple.againRequest = false
            }
            onNext(__tuple)
        })
        
        self.token = ""
        self.repLogin.accept(())
    }
}
