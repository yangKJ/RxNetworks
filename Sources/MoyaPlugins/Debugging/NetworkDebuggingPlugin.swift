//
//  NetworkDebuggingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/12/12.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 网络打印，DEBUG模式内置插件
/// Network printing, DEBUG mode built in plugin.
public final class NetworkDebuggingPlugin {
    
    /// Enable print request information.
    public var openDebugRequest: Bool = true
    /// Turn on printing the response result.
    public var openDebugResponse: Bool = true
    
    public init() { }
}

extension NetworkDebuggingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Debugging"
    }
    
    public func configuration(_ tuple: ConfigurationTuple, target: TargetType, plugins: APIPlugins) -> ConfigurationTuple {
        #if DEBUG
        printRequest(target, plugins: plugins)
        if let result = tuple.result {
            ansysisResult(target, result, local: true)
        }
        #endif
        return tuple
    }
    
    public func lastNever(_ tuple: LastNeverTuple, target: TargetType, onNext: @escaping LastNeverCallback) {
        #if DEBUG
        if let map = tuple.mapResult {
            switch map {
            case .success(let json):
                printResponse(target, json, false, true)
            case .failure(let error):
                printResponse(target, error.localizedDescription, false, false)
            }
        } else {
            ansysisResult(target, tuple.result, local: false)
        }
        #endif
        onNext(tuple)
    }
}

extension NetworkDebuggingPlugin {
    
    private func printRequest(_ target: TargetType, plugins: APIPlugins) {
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
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestFullLink(with: target))}}
                  ║-------------------------------------
                  ║ Plugins: \(pluginString(plugins))
                  ╚═══════════════════════════════════════
                  """)
        } else {
            print("""
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date) \(requestFullLink(with: target))
                  ║ URL: {{\(requestFullLink(with: target))}}
                  ║-------------------------------------
                  ║ Plugins: \(pluginString(plugins))
                  ╚═══════════════════════════════════════
                  """)
        }
    }
    
    private func pluginString(_ plugins: APIPlugins) -> String {
        return plugins.reduce("") { $0 + $1.pluginName + " " }
    }
    
    private func requestFullLink(with target: TargetType) -> String {
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
    
    private func ansysisResult(_ target: TargetType, _ result: Result<Moya.Response, MoyaError>, local: Bool) {
        switch result {
        case let .success(response):
            do {
                let response = try response.filterSuccessfulStatusCodes()
                let json = try response.mapJSON()
                printResponse(target, json, local, true)
            } catch MoyaError.jsonMapping(let response) {
                let error = MoyaError.jsonMapping(response)
                printResponse(target, error.localizedDescription, local, false)
            } catch MoyaError.statusCode(let response) {
                let error = MoyaError.statusCode(response)
                printResponse(target, error.localizedDescription, local, false)
            } catch {
                printResponse(target, error.localizedDescription, local, false)
            }
        case let .failure(error):
            printResponse(target, error.localizedDescription, local, false)
        }
    }
    
    private func printResponse(_ target: TargetType, _ json: Any, _ local: Bool, _ success: Bool) {
        guard openDebugResponse else { return }
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
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestFullLink(with: target))}}
                  ║-------------------------------------
                  ║ Method: \(target.method.rawValue)
                  ║ Host: \(target.baseURL.absoluteString)
                  ║ Path: \(target.path)
                  ║ Parameters: \(param)
                  ║ BaseParameters: \(NetworkConfig.baseParameters)
                  ║---------- 🎈 Response 🎈 ----------
                  ║ Result: \(success ? "Successed." : "Failed.")
                  ║ DataType: \(local ? "Local data." : "Remote data.")
                  ║ Response: \(json)
                  ╚═══════════════════════════════════════
                  """)
        } else {
            print("""
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestFullLink(with: target))}}
                  ║-------------------------------------
                  ║ Method: \(target.method.rawValue)
                  ║ Host: \(target.baseURL.absoluteString)
                  ║ Path: \(target.path)
                  ║ BaseParameters: \(NetworkConfig.baseParameters)
                  ║---------- 🎈 Response 🎈 ----------
                  ║ Result: \(success ? "Successed." : "Failed.")
                  ║ DataType: \(local ? "Local data." : "Remote data.")
                  ║ Response: \(json)
                  ╚═══════════════════════════════════════
                  """)
        }
    }
}
