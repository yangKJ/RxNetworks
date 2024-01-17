//
//  AppDelegate.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 生成授权凭证。用户没有登陆时，可以不生成。
        let credential = OAuthCredential.restore()

        // 生成授权中心
        let authenticator = OAuthenticator()
        // 使用授权中心和凭证（若没有可以不传）配置拦截器
        let interceptor = OAuthentication(authenticator: authenticator, credential: credential)
        NetworkConfig.interceptor = interceptor
        
        return true
    }
}
