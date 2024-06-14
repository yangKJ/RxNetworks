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
public struct NetworkDebuggingPlugin: HasPluginsPropertyProtocol {
    
    public var plugins: APIPlugins = []
    
    public let options: NetworkDebuggingPlugin.Options
    
    public init(options: NetworkDebuggingPlugin.Options = .concise) {
        self.options = options
    }
}

extension NetworkDebuggingPlugin {
    public struct Options: Equatable {
        /// This plugin has all the log records.
        public static let all = Options.init(logOptions: LogOptions.all)
        /// Concise printing log, has plugins and success body and error body.
        public static let concise = Options.init(logOptions: LogOptions.concise)
        /// Neither the request's nor the body of a response will be logged.
        public static let nothing = Options.init(logOptions: LogOptions.haveNothing)
        
        let logOptions: LogOptions
        
        public init(logOptions: LogOptions) {
            self.logOptions = logOptions
        }
    }
    
    /// Enable print request information.
    var openDebugRequest: Bool {
        if options.logOptions.contains(.requestMethod) {
            return true
        }
        if options.logOptions.contains(.requestBodyStream) {
            return true
        }
        if options.logOptions.contains(.requestHeaders) {
            return true
        }
        if options.logOptions.contains(.requestPlugins) {
            return true
        }
        if options.logOptions.contains(.requestParameters) {
            return true
        }
        return false
    }
    
    /// Turn on printing the response result.
    var openDebugResponse: Bool {
        if options.logOptions.contains(.successResponseBody) {
            return true
        }
        if options.logOptions.contains(.errorResponseBody) {
            return true
        }
        return false
    }
}

extension NetworkDebuggingPlugin.Options {
    public struct LogOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        /// Neither the request's nor the body of a response will be logged.
        public static let haveNothing: LogOptions = LogOptions(rawValue: 1 << 0)
        
        /// The request's method will be logged.
        public static let requestMethod: LogOptions = LogOptions(rawValue: 1 << 1)
        /// The request's body stream will be logged.
        public static let requestBodyStream: LogOptions = LogOptions(rawValue: 1 << 2)
        /// The request's headers will be logged.
        public static let requestHeaders: LogOptions = LogOptions(rawValue: 1 << 3)
        /// The request's parameters will be logged.
        public static let requestParameters: LogOptions = LogOptions(rawValue: 1 << 4)
        /// The request's plugins will be logged.
        public static let requestPlugins: LogOptions = LogOptions(rawValue: 1 << 5)
        
        /// The body of a response that is a success will be logged.
        public static let successResponseBody: LogOptions = LogOptions(rawValue: 1 << 87)
        /// The body of a response that is an error will be logged.
        public static let errorResponseBody: LogOptions = LogOptions(rawValue: 1 << 88)
        
        /// Enable print request information.
        public static let request: LogOptions = [requestMethod, requestBodyStream, requestHeaders, requestParameters, requestPlugins]
        /// Turn on printing the response result.
        public static let response: LogOptions = [successResponseBody, errorResponseBody]
        /// Open the request log and response log at the same time.
        public static let all: LogOptions = [request, response]
        /// Concise printing log.
        public static let concise: LogOptions = [requestPlugins, successResponseBody, errorResponseBody]
        /// Diversity printing log.
        public static let diversity: LogOptions = [requestPlugins, requestHeaders, requestParameters, successResponseBody, errorResponseBody]
    }
}

extension NetworkDebuggingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Debugging"
    }
    
    public var usePriorityLevel: UsePriorityLevel {
        UsePriorityLevel.low
    }
    
    public func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest {
        #if DEBUG
        if let result = request.result {
            let lastResult = OutputResult(result: result, mapped2JSON: false)
            ansysisResult(lastResult, target: target, local: true)
        }
        #endif
        return request
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        printRequest(request, target: target)
        #endif
    }
    
    public func outputResult(_ result: OutputResult, target: TargetType, onNext: @escaping OutputResultBlock) {
        #if DEBUG
        ansysisResult(result, target: target, local: false)
        #endif
        onNext(result)
    }
}

extension NetworkDebuggingPlugin {
    
    private var dateString: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale.current
            return formatter.string(from: Date())
        }
    }
    
    private func realParameters(target: TargetType) -> APIParameters? {
        guard options.logOptions.contains(.requestParameters) else {
            return nil
        }
        if case .requestParameters(let parame, _) = target.task {
            return parame
        }
        return nil
    }
    
    private func realHeaders(request: RequestType) -> [String: String]? {
        guard options.logOptions.contains(.requestHeaders) else {
            return nil
        }
        var allHeaders = request.sessionHeaders
        if let httpRequestHeaders = request.request?.allHTTPHeaderFields {
            allHeaders.merge(httpRequestHeaders) { $1 }
        }
        return allHeaders
    }
    
    private func realBodys(request: RequestType) -> String? {
        guard options.logOptions.contains(.requestBodyStream) else {
            return nil
        }
        return request.request?.httpBodyStream?.description
    }
    
    private func pluginsString() -> String? {
        guard options.logOptions.contains(.requestPlugins) else {
            return nil
        }
        return plugins.reduce("") { $0 + $1.className + " " }
    }
    
    private func printRequest(_ request: RequestType, target: TargetType) {
        guard openDebugRequest else {
            return
        }
        let requestLink = X.requestLink(with: target)
        let prefix = """
                    ╔════════ 🎷 Prepare Request 🎷 ════════
                    ║ Time: \(dateString)
                    ║ URL: \(requestLink)\n
                    """
        let suffix = """
                    ║--------------------------------------
                    ║ Advertis: 接各种App定制,有意请邮箱联系我,谢谢老板!!!
                    ║ Email: yangkj310@gmail.com
                    ╚══════════════════════════════════════
                    """
        var context: String = prefix
        if options.logOptions.contains(.requestMethod) {
            context += "║ Method: \(target.method.rawValue)\n"
        }
        if let value = realHeaders(request: request), !value.isEmpty {
            context += "║ Headers: \(value)\n"
        }
        if let value = realParameters(target: target), !value.isEmpty {
            context += "║ Parameters: \(value)\n"
        }
        if let value = realBodys(request: request), !value.isEmpty {
            context += "║ BodyStream: \(value)\n"
        }
        if let value = pluginsString() {
            context += """
                        ║--------------------------------------
                        ║ Plugins: \(value)\n
                        """
        }
        context += suffix
        print(context)
    }
    
    private func ansysisResult(_ result: OutputResult, target: TargetType, local: Bool) {
        if !openDebugResponse {
            return
        }
        result.mapResult(success: { json in
            if options.logOptions.contains(.successResponseBody) {
                printResponse(target, json, local, true)
            }
        }, failure: { error in
            if options.logOptions.contains(.errorResponseBody) {
                printResponse(target, error.localizedDescription, local, false)
            }
        }, setToMappedResult: false, mapped2JSON: true)
    }
    
    private func printResponse(_ target: TargetType, _ result: Any?, _ local: Bool, _ success: Bool) {
        guard openDebugResponse else {
            return
        }
        let requestLink = X.requestLink(with: target)
        let prefix = """
                    ╔═══════════ 🎈 Request 🎈 ═══════════
                    ║ Time: \(dateString)
                    ║ URL: \(requestLink)
                    ║--------------------------------------
                    ║ Method: \(target.method.rawValue)
                    ║ Host: \(target.baseURL.absoluteString)
                    ║ Path: \(target.path)\n
                    """
        let suffix = """
                    ║---------- 🎈 Response 🎈 ----------
                    ║ Result: \(success ? "Successed." : "Failed.")
                    ║ DataType: \(local ? "Local data." : "Remote data.")
                    ║ Response: \(result ?? "")
                    ╚══════════════════════════════════════
                    """
        var context: String = prefix
        if let param = realParameters(target: target), param.isEmpty == false {
            context += "║ Parameters: \(param)\n"
        }
        context += suffix
        print(context)
    }
}
