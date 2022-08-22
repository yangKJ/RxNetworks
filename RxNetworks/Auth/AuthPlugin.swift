//
//  AuthPlugin.swift
//  RxNetworks_Example
//
//  Created by cc on 2022/2/12.
//

import Foundation
import RxNetworks
import RxSwift
import RxCocoa

public final class AuthPlugin: NSObject {
    public static let NTF_Authed = Notification.Name.init("NTF_Authed")
    public static let NTF_Req_Login = Notification.Name.init("AuthPlugin.NTF_Req_Login")
    private (set) var token: String?
    fileprivate let lock = NSLock()
    public static let shared = AuthPlugin()
    
    private override init() {
        super.init()
        _ = NotificationCenter.default.rx
            .notification(AuthPlugin.NTF_Req_Login)
            .flatMapLatest({ _ -> Observable<String> in
                guard let token = AuthPlugin.shared.token, !token.isEmpty else {
                    print("--------[开始登陆]--------");
                    return Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
                        .take(1)
                        .do(onNext: { _ in
                            print("--------[登陆成功]--------");
                        })
                        .map({ _ in return "111" })
                }
                print("--------[getToken: \(token)]--------");
                return Observable<String>.just(token)
            }).subscribe(onNext: { token in
                NotificationCenter.default.post(name: AuthPlugin.NTF_Authed, object: token)
            })
    }
}

extension AuthPlugin: PluginSubType {
    public var pluginName: String {
        "AuthPlugin"
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let token = token, !token.isEmpty else {
            return request
        }
        var request = request
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
    
    public func lastNever(_ tuple: LastNeverTuple, target: TargetType, onNext: @escaping LastNeverCallback) {
        #if DEBUG
        guard self.token?.isEmpty ?? true else {
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
        // 处理401问题
        lock.lock()
        defer {
            lock.unlock()
        }
        
        _ = NotificationCenter.default.rx
            .notification(AuthPlugin.NTF_Authed)
            .take(1)
            .subscribe(onNext: { [weak self] ntf in
                guard let `self` = self else { return }
                self.token = ntf.object as? String
                var __tuple = tuple
                if !(self.token?.isEmpty ?? true) {
                    // 登陆成功后, 只需要重新请求接口，所以不需要response
                    __tuple.againRequest = true
                } else {
                    // 登陆失败后, 只需要统一401未授权状态即可，所以不需要data
                    let response = Moya.Response(statusCode: 401, data: Data())
                    __tuple.result = .failure(.statusCode(response))
                    __tuple.againRequest = false
                }
                onNext(__tuple)
                NotificationCenter.default.removeObserver(self, name: Self.NTF_Authed, object: nil)
            })
        NotificationCenter.default.post(name: Self.NTF_Req_Login, object: nil)
    }
}
