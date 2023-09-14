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
    
    static func handyConfigurationPlugin(_ plugins: APIPlugins, target: TargetType) -> ConfigurationTuple {
        var tuple: ConfigurationTuple
        tuple.result = nil // Empty data, convenient for subsequent plugin operations
        tuple.endRequest = false
        tuple.session = nil
        plugins.forEach { tuple = $0.configuration(tuple, target: target, plugins: plugins) }
        return tuple
    }
    
    static func handyResult(_ result: Result<Moya.Response, MoyaError>,
                            success: @escaping APISuccess,
                            failure: @escaping APIFailure,
                            progress: ProgressBlock?) {
        switch result {
        case let .success(response):
            do {
                let response = try response.filterSuccessfulStatusCodes()
                let jsonObject = try response.mapJSON()
                DispatchQueue.main.async { success(jsonObject) }
                // 直接进度拉满
                progress?(ProgressResponse(response: response))
            } catch MoyaError.jsonMapping(let response) {
                DispatchQueue.main.async { failure(MoyaError.jsonMapping(response)) }
            } catch MoyaError.statusCode(let response) {
                DispatchQueue.main.async { failure(MoyaError.statusCode(response)) }
            } catch {
                DispatchQueue.main.async { failure(error) }
            }
        case let .failure(error):
            DispatchQueue.main.async { failure(error) }
        }
    }
    
    static func handyLastNeverPlugin(_ plugins: APIPlugins,
                                     result: MoyaResult,
                                     target: TargetType,
                                     onNext: @escaping (LastNeverTuple)-> Void) {
        var tuple: LastNeverTuple
        tuple.result = result
        tuple.againRequest = false
        tuple.mapResult = nil
        var iterator = plugins.makeIterator()
        func handleLastNever(_ plugin: RxNetworks.PluginSubType?) {
            guard let _plugin = plugin else {
                onNext(tuple)
                return
            }
            _plugin.lastNever(tuple, target: target) { __tuple in
                tuple = __tuple
                handleLastNever(iterator.next())
            }
        }
        handleLastNever(iterator.next())
    }
    
    @discardableResult
    static func beginRequest(_ api: NetworkAPI,
                             base: MoyaProvider<MultiTarget>,
                             queue: DispatchQueue?,
                             success: @escaping APISuccess,
                             failure: @escaping APIFailure,
                             progress: ProgressBlock? = nil) -> Cancellable {
        // 处理结果数据
        func handleResult(_ result: MoyaResult, jsonResult: MapJSONResult?) {
            if let _jsonResult = jsonResult {
                switch _jsonResult {
                case let .success(json):
                    success(json)
                case let .failure(error):
                    failure(error)
                }
            } else {
                switch result {
                case let .success(response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let json = try response.mapJSON()
                        success(json)
                    } catch MoyaError.statusCode(let response) {
                        failure(MoyaError.statusCode(response))
                    } catch MoyaError.jsonMapping(let response) {
                        failure(MoyaError.jsonMapping(response))
                    } catch {
                        failure(error)
                    }
                case let .failure(error):
                    failure(error)
                }
            }
        }
        
        let target = MultiTarget.target(api)
        return base.request(target, callbackQueue: queue, progress: progress, completion: { result in
            guard let plugins = base.plugins as? [PluginSubType] else {
                DispatchQueue.main.async { handleResult(result, jsonResult: nil) }
                return
            }
            
            X.handyLastNeverPlugin(plugins, result: result, target: target) { tuple in
                if tuple.againRequest {
                    beginRequest(api, base: base, queue: queue, success: success, failure: failure, progress: progress)
                    return
                }
                DispatchQueue.main.async {
                    handleResult(tuple.result, jsonResult: tuple.mapResult)
                }
            }
        })
    }
}
