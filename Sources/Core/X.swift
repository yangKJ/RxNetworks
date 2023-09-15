//
//  NetworkX.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public struct X {
    
    /// Maps data received from the signal into a JSON object.
    public static func mapJSON<T>(_ type: T.Type, named: String, forResource: String = "RxNetworks") -> T? {
        guard let data = jsonData(named, forResource: forResource) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? T
    }
    
    /// Read json data
    public static func jsonData(_ named: String, forResource: String = "RxNetworks") -> Data? {
        let bundle: Bundle?
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: "bundle") {
            bundle = Bundle.init(path: bundlePath)
        } else {
            bundle = Bundle.main
        }
        guard let path = ["json", "JSON", "Json"].compactMap({
            bundle?.path(forResource: named, ofType: $0)
        }).first else {
            return nil
        }
        let contentURL = URL(fileURLWithPath: path)
        return try? Data(contentsOf: contentURL)
    }
    
    public static func toJSON(form value: Any, prettyPrint: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(value) else {
            return nil
        }
        var jsonData: Data? = nil
        if prettyPrint {
            jsonData = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
        } else {
            jsonData = try? JSONSerialization.data(withJSONObject: value, options: [])
        }
        guard let data = jsonData else { return nil }
        return String(data: data ,encoding: .utf8)
    }
    
    public static func toDictionary(form json: String) -> [String : Any]? {
        guard let jsonData = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let result = object as? [String : Any] else {
            return nil
        }
        return result
    }
}

// MARK: - internal tool methods

extension RxNetworks.X {
    
    /// 参数排序生成字符串
    static func sort(parameters: [String: Any]?) -> String {
        guard let params = parameters, !params.isEmpty else {
            return ""
        }
        var paramString = "?"
        let sorteds = params.sorted(by: { $0.key > $1.key })
        for index in sorteds.indices {
            paramString.append("\(sorteds[index].key)=\(sorteds[index].value)")
            if index != sorteds.count - 1 { paramString.append("&") }
        }
        return paramString
    }
    
    static func toJSON(with response: Moya.Response) throws -> APISuccessJSON {
        let response = try response.filterSuccessfulStatusCodes()
        return try response.mapJSON()
    }
    
    static func handyPlugins(_ plugins: APIPlugins) -> APIPlugins {
        return plugins.map({
            if var plugin = $0 as? Propertiesable {
                plugin.plugins = plugins
                return plugin
            }
            return $0
        })
    }
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> HeadstreamRequest {
        var request = HeadstreamRequest()
        plugins.forEach { request = $0.configuration(request, target: target) }
        return request
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins,
                                     result: Result<Moya.Response, MoyaError>,
                                     target: TargetType,
                                     onNext: @escaping (LastNeverResult)-> Void) {
        var lastResult = LastNeverResult.init(result: result)
        var iterator = plugins.makeIterator()
        func handleLastNever(_ plugin: RxNetworks.PluginSubType?) {
            guard let plugin = plugin else {
                onNext(lastResult)
                return
            }
            plugin.lastNever(lastResult, target: target) {
                lastResult = $0
                handleLastNever(iterator.next())
            }
        }
        handleLastNever(iterator.next())
    }
    
    @discardableResult static func request(target: MultiTarget,
                                           provider: MoyaProvider<MultiTarget>,
                                           queue: DispatchQueue?,
                                           success: @escaping APISuccess,
                                           failure: @escaping APIFailure,
                                           progress: ProgressBlock? = nil) -> Cancellable {
        return provider.request(target, callbackQueue: queue, progress: progress, completion: { result in
            guard let plugins = provider.plugins as? [PluginSubType] else {
                let lastResult = LastNeverResult(result: result)
                lastResult.handy(success: success, failure: failure)
                return
            }
            handyLastNeverPlugin(plugins, result: result, target: target) { lastResult in
                if lastResult.againRequest {
                    request(target: target, provider: provider, queue: queue, success: success, failure: failure, progress: progress)
                    return
                }
                lastResult.handy(success: success, failure: failure)
            }
        })
    }
}
