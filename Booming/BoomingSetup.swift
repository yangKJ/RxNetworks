//
//  BoomingSetup.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire

@available(*, deprecated, message: "Typo. Use `BoomingSetup` instead", renamed: "BoomingSetup")
public typealias NetworkConfig = BoomingSetup

/// 网络配置信息，只需要在程序开启的时刻配置一次
/// Network configuration information, only need to be configured once when the program is started
public struct BoomingSetup {
    
    /// Whether to add the Indicator plugin by default.
    public static var addIndicator: Bool = false
    #if BOOMING_PLUGINGS_SHARED
    /// 默认日志插件
    public static var debuggingLogOption: NetworkDebuggingPlugin.Options = .concise
    #endif
    
    /// Set the request timeout, the default is 30 seconds.
    public static var timeoutIntervalForRequest: Double = 30
    
    /// Whether to support background URLSessionConfigurations with Alamofire.
    public static var supportBackgroundRequest: Bool = false
    /// Determines whether this instance will automatically start all requests.
    /// If set to `false`, all requests created must have `.resume()` called. on them for them to start.
    public static var startRequestsImmediately: Bool = false
    
    /// Root path address.
    public static var baseURL: APIHost = ""
    /// Default request type, default `post`
    public static var baseMethod: APIMethod = APIMethod.post
    /// Default basic parameters, similar to: userID, token, etc.
    public static var baseParameters: APIParameters = [:]
    /// Default Header argument, When the same data is the same, the data will be overwritten by the `NetworkHttpHeaderPlugin` plug-in.
    public static var baseHeaders: [String: String] = [:]
    /// Plugins that require default injection, generally not recommended.
    /// However, you can inject this kind of global unified general plugin, such as secret key plugin, certificate plugin, etc.
    public static var basePlugins: [PluginSubType]?
    
    /// Loading animation JSON, for `AnimatedLoadingPlugin` used.
    public static var animatedJSON: String?
    /// Loading the plugin name, to remove the loading plugin from level status bar window.
    public static var loadingPluginNames: [String] = ["Loading", "AnimatedLoading"]
    /// Auto close all loading after the end of the last network requesting.
    public static var lastCompleteAndCloseLoadingHUDs: Bool = true
    
    /// Maps data received from the signal into a JSON object, when the data is empty mapping should fail.
    public static var failsOnEmptyData: Bool = true
    
    /// Update the default basic parameter data, which is generally used for what operation the user has switched.
    /// - Parameters:
    ///   - value: Update value
    ///   - key: Update key
    public static func updateBaseParametersWithValue(_ value: AnyObject?, key: String) {
        var dict = Self.baseParameters
        if let value = value {
            dict.updateValue(value, forKey: key)
        } else {
            dict.removeValue(forKey: key)
        }
        Self.baseParameters = dict
    }
}

extension BoomingSetup {
    @available(*, deprecated, message: "Use `NetworkAuthenticationPlugin` add to `BoomingSetup.basePlugins`")
    /// It is recommended to use plug-in mode to add interceptor.
    /// You can also add it to the `BoomingSetup.basePlugins`.
    public static var interceptor: RequestInterceptor? = nil
    
    @available(*, deprecated, message: "Use `BoomingSetup.debuggingLogOption`, if you set false correspond to `BoomingSetup.debuggingLogOption = .none`")
    /// Whether to add the Debugging plugin by default.
    public static var addDebugging: Bool = true {
        didSet {
            if !addDebugging {
                debuggingLogOption = .none
            }
        }
    }
}
