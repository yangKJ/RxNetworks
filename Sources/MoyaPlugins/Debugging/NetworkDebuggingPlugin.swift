//
//  NetworkDebuggingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/12/12.
//

import Foundation
import RxSwift
import Moya

/// 网络打印，DEBUG模式内置插件
/// Network printing, DEBUG mode built in plugin.
public final class NetworkDebuggingPlugin {
    
    /// Enable print request information.
    public static var openDebugRequest: Bool = true
    /// Turn on printing the response result.
    public static var openDebugResponse: Bool = true
    
    public init() { }
}

extension NetworkDebuggingPlugin: PluginSubType {
    
    public func configuration(_ tuple: ConfigurationTuple, target: TargetType, plugins: APIPlugins) -> ConfigurationTuple {
        #if DEBUG
        NetworkDebuggingPlugin.DebuggingRequest(target, plugins: plugins)
        if let result = tuple.result {
            NetworkDebuggingPlugin.ansysisResult(result, local: true)
        }
        #endif
        return tuple
    }
    
    public func lastNever(_ tuple: LastNeverTuple, target: TargetType) -> LastNeverTuple {
        #if DEBUG
        if let map = tuple.mapResult {
            switch map {
            case .success(let json):
                NetworkDebuggingPlugin.DebuggingResponse(json, false, true)
            case .failure(let error):
                NetworkDebuggingPlugin.DebuggingResponse(error.localizedDescription, false, false)
            }
        } else {
            NetworkDebuggingPlugin.ansysisResult(tuple.result, local: false)
        }
        #endif
        return tuple
    }
}

extension NetworkDebuggingPlugin {
    
    static func DebuggingRequest(_ target: TargetType, plugins: APIPlugins) {
        guard openDebugRequest else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        var parameters: APIParameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        if let param = parameters, param.isEmpty == false {
            print("""
                  ------- 🎈 Request 🎈 -------
                  Time: \(date)
                  Method: \(target.method.rawValue)
                  Host: \(target.baseURL.absoluteString)
                  Path: \(target.path)
                  Parameters: \(param)
                  BaseParameters: \(NetworkConfig.baseParameters)
                  Plugins: \(pluginString(plugins))
                  LinkURL: \(requestFullLink(with: target))
                  
                  """)
        } else {
            print("""
              ------- 🎈 Request 🎈 -------
              Time: \(date)
              Method: \(target.method.rawValue)
              Host: \(target.baseURL.absoluteString)
              Path: \(target.path)
              BaseParameters: \(NetworkConfig.baseParameters)
              Plugins: \(pluginString(plugins))
              LinkURL: \(requestFullLink(with: target))
              
              """)
        }
    }
    
    private static func pluginString(_ plugins: APIPlugins) -> String {
        var string = ""
        plugins.forEach { plugin in
            let clazz = String(describing: plugin)
            let name = String(clazz.split(separator: ".").last ?? "")
            string.append(name + ", ")
        }
        return string
    }
    
    private static func requestFullLink(with target: TargetType) -> String {
        var parameters: APIParameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        guard let parameters = parameters, !parameters.isEmpty else {
            return target.baseURL.absoluteString + target.path
        }
        let sortedParameters = parameters.sorted(by: { $0.key > $1.key })
        var paramString = "?"
        for index in sortedParameters.indices {
            paramString.append("\(sortedParameters[index].key)=\(sortedParameters[index].value)")
            if index != sortedParameters.count - 1 { paramString.append("&") }
        }
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
}

extension NetworkDebuggingPlugin {
    
    static func ansysisResult(_ result: Result<Moya.Response, MoyaError>, local: Bool) {
        switch result {
        case let .success(response):
            do {
                let response = try response.filterSuccessfulStatusCodes()
                let json = try response.mapJSON()
                NetworkDebuggingPlugin.DebuggingResponse(json, local, true)
            } catch MoyaError.jsonMapping(let response) {
                let error = MoyaError.jsonMapping(response)
                NetworkDebuggingPlugin.DebuggingResponse(error.localizedDescription, local, false)
            } catch MoyaError.statusCode(let response) {
                let error = MoyaError.statusCode(response)
                NetworkDebuggingPlugin.DebuggingResponse(error.localizedDescription, local, false)
            } catch {
                NetworkDebuggingPlugin.DebuggingResponse(error.localizedDescription, local, false)
            }
        case let .failure(error):
            NetworkDebuggingPlugin.DebuggingResponse(error.localizedDescription, local, false)
        }
    }
    static func DebuggingResponse(_ json: Any, _ local: Bool, _ success: Bool) {
        guard openDebugResponse else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        print("""
              ------- 🎈 Response 🎈 -------
              Time: \(date)
              Result: \(success ? "Successed." : "Failed.")
              DataType: \(local ? "Local data." : "Remote data.")
              Response: \(json)
              
              """)
    }
}
