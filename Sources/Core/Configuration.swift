//
//  NetworkConfig.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire

/// 网络配置信息，只需要在程序开启的时刻配置一次
/// Network configuration information, only need to be configured once when the program is started
public struct NetworkConfig {
    
    /// Whether to add the Debugging plugin by default
    public static var addDebugging: Bool = false
    /// Whether to add the Indicator plugin by default
    public static var addIndicator: Bool = false
    /// Plugins that require default injection, generally not recommended
    /// However, you can inject this kind of global unified general plugin, such as secret key plugin, certificate plugin, etc.
    public static var injectionPlugins: [PluginSubType]?
    /// Set the request timeout, the default is 30 seconds
    public static var timeoutIntervalForRequest: Double = 30
    
    /// Root path address
    public static var baseURL: APIHost = ""
    /// Default basic parameters, similar to: userID, token, etc.
    public static var baseParameters: APIParameters = [:]
    /// Default request type, default `post`
    public static var baseMethod: APIMethod = APIMethod.post
    /// Default Header argument
    public static var baseHeaders: [String:String] = [:]
    
    /// Loading animation JSON, for `AnimatedLoadingPlugin` used.
    public static var animatedJSON: String?
    /// Loading the plugin name, to remove the loading plugin from level status bar window.
    public static var loadingPluginNames: [String] = ["Loading", "AnimatedLoading"]
    /// Auto close all loading after the end of the last network requesting.
    public static var lastCompleteAndCloseLoadingHUDs: Bool = true
    
    /// Update the default basic parameter data, which is generally used for what operation the user has switched.
    /// - Parameters:
    ///   - value: Update value
    ///   - key: Update key
    public static func updateBaseParametersWithValue(_ value: AnyObject?, key: String) {
        var dict = NetworkConfig.baseParameters
        if let value = value {
            dict.updateValue(value, forKey: key)
        } else {
            dict.removeValue(forKey: key)
        }
        NetworkConfig.baseParameters = dict
    }
}
