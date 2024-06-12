//
//  OOViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa
import NetworkHudsPlugin

class OOViewModel: NSObject {
    
    let userDefaultsCache = UserDefaults(suiteName: "userDefaultsCache")!
    
    func request(block: @escaping (String) -> Void) {
        let api = NetworkAPIOO.init()
        api.ip = "https://www.httpbin.org"
        api.path = "/headers"
        api.method = APIMethod.get
        api.plugins = [
            NetworkLoadingPlugin(options: .init(text: "OOing..")),
            NetworkCustomCachePlugin.init(cacheType: .cacheThenNetwork, cacher: userDefaultsCache),
            NetworkIgnorePlugin(pluginTypes: [NetworkActivityPlugin.self]),
        ]
        api.mapped2JSON = false
        api.request(successed: { _, _, response in
            guard let json = try? response.toJSON().get(),
                  let string = X.toJSON(form: json, prettyPrint: true) else {
                return
            }
            block(string)
        })
    }
}

extension UserDefaults: CacheConvertable {
    
    public func readResponse(forKey key: String) throws -> Moya.Response? {
        guard let data = data(forKey: key + "_response_data") else {
            return nil
        }
        let statusCode = integer(forKey: key + "_response_statusCode")
        return Moya.Response(statusCode: statusCode, data: data)
    }
    
    public func saveResponse(_ response: Moya.Response, forKey key: String) throws {
        set(response.data, forKey: key + "_response_data")
        set(response.statusCode, forKey: key + "_response_statusCode")
    }
    
    public func clearAllResponses() {
        let dict = dictionaryRepresentation()
        for key in dict.keys {
            removeObject(forKey: key)
        }
    }
}
