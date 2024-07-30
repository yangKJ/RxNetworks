# Booming

### Core
This module is based on the Moya encapsulated network API architecture.

- Mainly divided into parts:
    - [BoomingSetup](https://github.com/yangKJ/RxNetworks/blob/master/Booming/BoomingSetup.swift): Set the configuration information at the beginning of the program.
        - **basePlugins**：Plugins that require default injection, generally not recommended.
        - **baseURL**: Root path address to base URL.
        - **baseParameters**: Default basic parameters, like: userID, token, etc.
        - **baseMethod**: Default request method type.
        - **updateBaseParametersWithValue**: Update default base parameter value.
    - [PluginSubType](https://github.com/yangKJ/RxNetworks/blob/master/Booming/PluginSubType.swift): Inherit and replace the Moya plug-in protocol to facilitate subsequent expansion.
         - **configuration**: After setting the network configuration information, this method can be used in scenarios such as throwing data directly when the local cache exists without executing subsequent network requests.
         - **lastNever**: When the last network response is returned, this method can be used in scenarios such as key failure to re-obtain the key and then automatically re-request the network.
    - [NetworkAPI](https://github.com/yangKJ/RxNetworks/blob/master/Booming/NetworkAPI.swift): Add protocol attributes and encapsulate basic network requests based on TargetType.
        - **ip**: Root path address to base URL.
        - **parameters**: Request parameters.
        - **plugins**: Set network plugins.
        - **stubBehavior**: Whether to take the test data.
        - **retry**：Network request failure retries.
        - **request**: Network request method and return a Single sequence object.
    - [NetworkAPI+Ext](https://github.com/yangKJ/RxNetworks/blob/master/Booming/NetworkAPI+Ext.swift): Protocol default implementation scheme.
    - [NetworkAPIOO](https://github.com/yangKJ/RxNetworks/blob/master/Booming/NetworkAPIOO.swift): OOP converter, MVP to OOP, convenient for friends who are used to OC thinking
        - **ip**: Root path address to base URL.
        - **path**: Request path.
        - **parameters**: Request parameters.
        - **plugins**: Set network plugins.
        - **testData**: Network test data.
        - **testTime**: Network test data return time, the default is half a second.
        - **request:successed:failed:**: Network request method.
    - [X](https://github.com/yangKJ/RxNetworks/blob/master/Booming/X.swift): extension function methods etc.
        - **mapJSON**: to JSON string.
        - **toDictionary**: JSON string to dictionary.
        
### Usage
Provide some test cases for reference.🚁

- OO Example 1:

```
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
        api.request(successed: { response in
            guard let string = response.bpm.toJSONString(prettyPrint: true) else {
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
```

- MVP Example 2:

```
enum LoadingAPI {
    case test2(String)
}

extension LoadingAPI: NetworkAPI {
    
    var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        switch self {
        case .test2(let string):
            return ["key": string]
        }
    }
    
    var plugins: APIPlugins {
        var options = NetworkLoadingPlugin.Options.init(delay: 2)
        options.setChangeHudParameters { hud in
            hud.detailsLabel.text = "Loading"
            hud.detailsLabel.textColor = UIColor.yellow
        }
        let loading = NetworkLoadingPlugin.init(options: options)
        return [loading]
    }
}


class LoadingViewModel: NSObject {
    
    @MainActor
    func request(block: @escaping (_ text: String?) -> Void) {
        Task {
            do {
                let response = try await LoadingAPI.test2("666").requestAsync()
                let json = response.bpm.mappedJson
                let model = LoadingModel.deserialize(from: json, designatedPath: "data", options: .CodingKeysConvertFromSnakeCase)
                block(model?.toJSONString(prettyPrint: true))
            } catch {
                block(error.localizedDescription)
            }
        }
    }
}
```

- MVVM Example 3:

```
class CacheViewModel: NSObject {
    struct Input {
        let count: Int
    }
    struct Output {
        let items: Observable<[CacheModel]>
    }
    
    func transform(input: Input) -> Output {
        let items = request(input.count).asObservable()
        
        return Output(items: items)
    }
}

extension CacheViewModel {
    
    func request(_ count: Int) -> Observable<[CacheModel]> {
        CacheAPI.cache(count).request()
            .deserialize(ApiResponse<[CacheModel]>.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance) // the result is returned on the main thread
            .catchAndReturn([]) // return null on error
    }
}
```

- Chain Example 4:

```
class ChainViewModel: NSObject {
    
    struct Input { }
    
    struct Output {
        let data: Observable<NSDictionary>
    }
    
    func transform(input: Input) -> Output {
        let data = chain().asObservable()
        
        return Output(data: data)
    }
    
    func chain() -> Observable<NSDictionary> {
        Observable.from(optional: "begin")
            .flatMapLatest(requestIP)
            .flatMapLatest(requestData(ip:))
            .catchAndReturn([:])
    }
}

extension ChainViewModel {
    
    func requestIP(_ stirng: String) -> Observable<String> {
        return ChainAPI.test.request()
            .asObservable()
            .map { (($0 as? NSDictionary)?["origin"] as? String) ?? stirng }
            .observe(on: MainScheduler.instance)
    }
    
    func requestData(ip: String) -> Observable<NSDictionary> {
        return ChainAPI.test2(ip).request()
            .map { ($0 as! NSDictionary) }
            .catchAndReturn(["data": "nil"])
            .observe(on: MainScheduler.instance)
    }
}
```

- Batch Example 5:

```
class BatchViewModel: NSObject {
    
    struct Input { }
    
    struct Output {
        let data: Observable<[String: Any]>
    }
    
    func transform(input: Input) -> Output {
        let data = batch().asObservable()
        
        return Output(data: data)
    }
    
    func batch() -> Observable<[String: Any]> {
        Observable.zip(
            BatchAPI.test.request(),
            BatchAPI.test2("666").request(),
            BatchAPI.test3.request()
        )
        .observe(on: MainScheduler.instance)
        .map { [$0, $1, $2].compactMap {
            $0 as? [String: Any]
        }}
        .map { $0.reduce([String: Any](), +==) }
        .catchAndReturn([:])
    }
}
```
