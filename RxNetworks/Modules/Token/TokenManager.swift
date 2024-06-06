//
//  TokenManager.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/5/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

class TokenManager {
    
    @UserDefault_("condy_token", defaultValue: "")
    private(set) var token: String
    
    static let shared = TokenManager()
    
    private let lock = NSLock()
    
    private init() { }
    
    func setToken(_ token: String) {
        self.lock.lock()
        self.token = token
        print("token: - \(token)")
        self.lock.unlock()
    }
    
    func reqLogin(complete: @escaping (_ token: String) -> Void) {
        print("--------[开始登陆]--------")
        // 模拟获取token
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let token = UUID().uuidString
            self.setToken(token)
            print("--------[登陆成功]--------")
            complete(token)
        }
    }
}
