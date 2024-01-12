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
public struct NetworkDebuggingPlugin: PluginPropertiesable {
    
    public var plugins: APIPlugins = []
    
    public var key: String?
    
    public let options: Options
    
    public init(options: Options = .default) {
        self.options = options
    }
}

extension NetworkDebuggingPlugin {
    public struct Options {
        
        public static let `default`: Options = .init(logOptions: .default)
        
        let logOptions: LogOptions
        
        public init(logOptions: LogOptions) {
            self.logOptions = logOptions
        }
    }
    
    /// Enable print request information.
    var openDebugRequest: Bool {
        switch options.logOptions {
        case .request, .`default`:
            return true
        default:
            return false
        }
    }
    /// Turn on printing the response result.
    var openDebugResponse: Bool {
        switch options.logOptions {
        case .response, .`default`:
            return true
        default:
            return false
        }
    }
}

extension NetworkDebuggingPlugin.Options {
    public struct LogOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        /// Enable print request information.
        public static let request: LogOptions = LogOptions(rawValue: 1 << 0)
        /// Turn on printing the response result.
        public static let response: LogOptions = LogOptions(rawValue: 1 << 1)
        /// Open the request log and response log at the same time.
        public static let `default`: LogOptions = [request, response]
    }
}

extension NetworkDebuggingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Debugging"
    }
    
    public func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest {
        #if DEBUG
        printRequest(target, plugins: plugins)
        if let result = request.result {
            let lastResult = LastNeverResult(result: result, plugins: plugins)
            ansysisResult(lastResult, target: target, local: true)
        }
        #endif
        return request
    }
    
    public func lastNever(_ result: LastNeverResult, target: TargetType, onNext: @escaping LastNeverCallback) {
        #if DEBUG
        ansysisResult(result, target: target, local: false)
        #endif
        onNext(result)
    }
}

extension NetworkDebuggingPlugin {
    
    private func printRequest(_ target: TargetType, plugins: APIPlugins) {
        guard openDebugRequest else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        let parameters = (target as? NetworkAPI)?.parameters
        let requestLink = X.requestLink(with: target, parameters: parameters)
        if let param = parameters, param.isEmpty == false {
            print("""
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestLink)}}
                  ║-------------------------------------
                  ║ Plugins: \(pluginString(plugins))
                  ╚═════════════════════════════════════
                  """)
        } else {
            print("""
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestLink)}}
                  ║-------------------------------------
                  ║ Plugins: \(pluginString(plugins))
                  ╚═════════════════════════════════════
                  """)
        }
    }
    
    private func pluginString(_ plugins: APIPlugins) -> String {
        return plugins.reduce("") { $0 + $1.pluginName + " " }
    }
}

extension NetworkDebuggingPlugin {
    
    private func ansysisResult(_ lastResult: LastNeverResult, target: TargetType, local: Bool) {
        lastResult.mapResult(success: { response in
            printResponse(target, response, local, true)
        }, failure: { error in
            printResponse(target, error.localizedDescription, local, false)
        })
    }
    
    private func printResponse(_ target: TargetType, _ response: Any, _ local: Bool, _ success: Bool) {
        guard openDebugResponse else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        let date = formatter.string(from: Date())
        let parameters = (target as? NetworkAPI)?.parameters
        let requestLink = X.requestLink(with: target, parameters: parameters)
        let prefix = """
                  ╔═══════════ 🎈 Request 🎈 ═══════════
                  ║ Time: \(date)
                  ║ URL: {{\(requestLink)}}
                  ║-------------------------------------
                  ║ Method: \(target.method.rawValue)
                  ║ Host: \(target.baseURL.absoluteString)
                  ║ Path: \(target.path)
                  ║ BaseParameters: \(NetworkConfig.baseParameters)\n
                  """
        let suffix = """
                  ║---------- 🎈 Response 🎈 ----------
                  ║ Result: \(success ? "Successed." : "Failed.")
                  ║ DataType: \(local ? "Local data." : "Remote data.")
                  ║ Response: \(response)\n
                  """
        var context: String = ""
        if let param = parameters, param.isEmpty == false {
            context = prefix + "║ Parameters: \(param)\n" + suffix
        } else {
            context = prefix + suffix
        }
        if let downloadURL = X.hasNetworkFilesPlugin(plugins) {
            context += "║ DownloadURL: \(downloadURL)\n"
        }
        context += "╚═════════════════════════════════════"
        print(context)
    }
}
