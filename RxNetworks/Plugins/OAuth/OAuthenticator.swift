//
//  OAuthenticator.swift
//  NetWorking
//
//  Created by cc on 2023/12/19.
//  Copyright © 2023 cc.doky. All rights reserved.
//

import Foundation
import Alamofire
import Moya

public struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    let uid: String
    let expiration: Date

    // 这里我们在有效期即将过期的5分钟返回需要刷新
    public var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 5) > expiration }
    
    /// 是否登录成功
    fileprivate static var isLogined = false
    /// 正在登录流程
    fileprivate static var isLoging = false
    fileprivate static let lock = NSLock()
    var isLogined: Bool {
        return Self.isLogined && !self.accessToken.isEmpty
    }
}

extension OAuthCredential {
    func store() {
        let dict: [String : Any] = [
            "accessToken": accessToken,
            "refreshToken": refreshToken,
            "uid": uid,
            "expir": expiration.timeIntervalSince1970
        ]
        UserDefaults.standard.setValue(dict, forKey: "OAuthCredential")
    }
    
    static func restore()-> OAuthCredential {
        let dict = UserDefaults.standard.object(forKey: "OAuthCredential") as? [String: Any]
        let expir = dict?["expir"] as? Double ?? 0
        let auth = OAuthCredential(
            accessToken: dict?["accessToken"] as? String ?? "",
            refreshToken: dict?["refreshToken"] as? String ?? "",
            uid: dict?["uid"] as? String ?? "",
            expiration: (expir == 0 ? Date(timeIntervalSinceNow: 60 * 5) : Date(timeIntervalSince1970: expir))
        )
        Self.isLogined = !auth.accessToken.isEmpty
        return auth
    }
    
    static func logout() {
        self.isLogined = false
        UserDefaults.standard.removeObject(forKey: "OAuthCredential")
        //OAuthentication.shared.logout()
    }
    
    static func login(
        accessToken: String,
        refreshToken: String,
        uid: String
    ) {
        self.isLogined = true
        let dict: [String: Any] = [
            "accessToken": accessToken,
            "refreshToken": refreshToken,
            "uid": uid,
            "expir": Date(timeIntervalSinceNow: 60 * 30).timeIntervalSince1970
        ]
        UserDefaults.standard.setValue(dict, forKey: "OAuthCredential")
    }
    
    /// 发起登录请求，
    /// 弹出登录页面，进行登录
    static func reqLogin() {
        lock.lock()
        defer {
            lock.unlock()
        }
        if (self.isLoging || self.isLogined) {
            return
        }
        self.isLoging = true
        /*
        let para = R_BizMaster.PRLogin {
            self.isLoging = false
        }
        DispatchQueue.main.async {
            Mediator.shared.present(R_BizMaster.login, context: para)
        }
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isLoging = false
            OAuthCredential.login(
                accessToken: "${YOUR ACCESSTOKEN}",
                refreshToken: "${YOUR REFRESHTOKEN}",
                uid: "${YOUR USERID}"
            )
        }
    }
}

public extension TargetType {
    var validationType: ValidationType {
        return .successCodes
    }
}

public class OAuthenticator: Authenticator {
    /// 添加header
    public func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
        urlRequest.headers.add(name: "time_zone", value: TimeZone.current.identifier)
        urlRequest.headers.add(name: "uid", value: credential.uid)
    }
    /// 实现刷新流程
    public func refresh(_ credential: OAuthCredential,
                 for session: Session,
                 completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
        let __error = NSError(domain: "", code: 401)
        if !credential.isLogined {
            /// 未登录时，去登录
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // 检查是否登录成功
                let __credential = OAuthCredential.restore()
                if __credential.isLogined {
                    completion(.success(__credential))
                } else {
                    completion(.failure(__error))
                }
            }
        } else if !credential.refreshToken.isEmpty {
            /// 已登录的情况下，还返回 401 说明登录过期，刷新 token
            /*
            _ = ApiLogin.refresh_token(credential.refreshToken)
                .request()
                .decode(ApiResponse<MLogin>.self)
                .subscribe(onNext: { response in
                    guard let info = response.data else {
                        OAuthCredential.logout()
                        completion(.failure(__error))
                        return
                    }
                    OAuthCredential.login(
                        accessToken: info.access_token,
                        refreshToken: info.refresh_token,
                        uid: credential.uid
                    )
                    let __credential = OAuthCredential.restore()
                    completion(.success(__credential))
                }, onError: { error in
                    completion(.failure(error))
                })
             */
            /// 请修改以上注释部分代码
            OAuthCredential.login(
                accessToken: "${YOUR ACCESSTOKEN}",
                refreshToken: "${YOUR REFRESHTOKEN}",
                uid: "${YOUR USERID}"
            )
            let __credential = OAuthCredential.restore()
            completion(.success(__credential))
        } else {
            completion(.failure(__error))
        }
    }

    public func didRequest(_ urlRequest: URLRequest,
                    with response: HTTPURLResponse,
                    failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == 401
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        if (!credential.isLogined) {
            // 去刷新 token 或者登录
            return true
        }
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }
}
