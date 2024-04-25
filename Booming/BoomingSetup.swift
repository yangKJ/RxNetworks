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
    
    /// Whether to add the Debugging plugin by default
    public static var addDebugging: Bool = false
    /// Whether to add the Indicator plugin by default
    public static var addIndicator: Bool = false
    /// Set the request timeout, the default is 30 seconds
    public static var timeoutIntervalForRequest: Double = 30
    
    public static var interceptor: RequestInterceptor? = nil
    /// Root path address
    public static var baseURL: APIHost = ""
    /// Default request type, default `post`
    public static var baseMethod: APIMethod = APIMethod.post
    /// Default basic parameters, similar to: userID, token, etc.
    public static var baseParameters: APIParameters = [:]
    /// Default Header argument, 相同数据时该数据会被`NetworkHttpHeaderPlugin`插件覆盖.
    public static var baseHeaders: [String: String] = [:]
    /// Plugins that require default injection, generally not recommended
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
