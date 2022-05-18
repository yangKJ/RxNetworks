//
//  NetworkConfig.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

///`Moya`文档
/// https://github.com/Moya/Moya
///
///`SwiftyJSON`文档
/// https://github.com/SwiftyJSON/SwiftyJSON

import Foundation
import Alamofire
import Moya

public typealias APIHost = String
public typealias APIPath = String
public typealias APINumber = Int
public typealias APIMethod = Moya.Method
public typealias APIParameters = Alamofire.Parameters
public typealias APIPlugins = [RxNetworks.PluginSubType]
public typealias APIStubBehavior = Moya.StubBehavior

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
    public static var timeoutIntervalForRequest: TimeInterval = 30
    
    /// Root path address
    public private(set) static var baseURL: APIHost = ""
    /// Default basic parameters, similar to: userID, token, etc.
    public private(set) static var baseParameters: APIParameters = [:]
    /// Default request type, default `post`
    public private(set) static var baseMethod: APIMethod = APIMethod.post
    /// Default Header argument
    public static var baseHeaders: [String:String] = [:]
    
    /// Configuration information
    /// - Parameters:
    ///   - host: Root path address.
    ///   - parameters: Default basic parameters, similar to: userID, token, etc.
    ///   - method: Default request type, default `post`
    public static func setupDefault(host: APIHost = "",
                                    parameters: APIParameters = [:],
                                    method: APIMethod = APIMethod.post) {
        self.baseURL = host
        self.baseParameters = parameters
        self.baseMethod = method
    }
    
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
