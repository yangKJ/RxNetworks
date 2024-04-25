# Booming

### Core
This module is based on the Moya encapsulated network API architecture.

- Mainly divided into parts:
    - [BoomingSetup](https://github.com/yangKJ/RxNetworks/blob/master/Booming/BoomingSetup.swift): Set the configuration information at the beginning of the program.
        - **addDebugging**：Whether to introduce the debug mode plugin by default.
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
        - **cdy_ip**: Root path address to base URL.
        - **cdy_path**: Request path.
        - **cdy_parameters**: Request parameters.
        - **cdy_plugins**: Set network plugins.
        - **cdy_testJSON**: Network testing json string.
        - **cdy_testTime**: Network test data return time, the default is half a second.
        - **cdy_HTTPRequest**: Network request method and return a Single sequence object.
    - [X](https://github.com/yangKJ/RxNetworks/blob/master/Booming/X.swift): extension function methods etc.
        - **defaultPlugin**: Add default plugin.
        - **transformAPIObservableJSON**: Transforms a `Observable` sequence JSON object.
        - **handyConfigurationPlugin**: Handles configuration plugins.
        - **toJSON**: to JSON string.
        - **toDictionary**: JSON string to dictionary.
        - **+=**: Dictionary concatenation.
        
### Usage
Provide some test cases for reference.🚁

- OO Example 1:

```
class OOViewModel: NSObject {
    struct Input {
        let retry: Int
    }
    struct Output {
        let items: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        return Output(items: input.request())
    }
}

extension OOViewModel.Input {
    func request() -> Observable<String> {
        var api = NetworkAPIOO.init()
        api.cdy_ip = BoomingSetup.baseURL
        api.cdy_path = "/ip"
        api.cdy_method = APIMethod.get
        api.cdy_plugins = [NetworkLoadingPlugin()]
        api.cdy_retry = self.retry
        
        return api.cdy_HTTPRequest()
            .asObservable()
            .compactMap{ (($0 as! NSDictionary)["origin"] as? String) }
            .catchAndReturn("")
            .observe(on: MainScheduler.instance)
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
    
    func request(block: @escaping (_ text: String?) -> Void) {
        LoadingAPI.test2("666").request(complete: { result in
            switch result {
            case .success(let json):
                if let model = Deserialized<LoadingModel>.toModel(with: json) {
                    DispatchQueue.main.async {
                        block(model.origin)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    block(error.localizedDescription)
                }
            }
        })
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
            .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance) // the result is returned on the main thread
            .catchAndReturn([]) // return null on error
    }
}
```

- Chain Example 4:

```
class ChainViewModel: NSObject {
    let disposeBag = DisposeBag()
    let data = PublishRelay<NSDictionary>()
    
    func chainLoad() {
        requestIP()
            .flatMapLatest(requestData)
            .subscribe(onNext: { [weak self] data in
                self?.data.accept(data)
            }, onError: {
                print("Network Failed: \($0)")
            }).disposed(by: disposeBag)
    }
}

extension ChainViewModel {
    func requestIP() -> Observable<String> {
        return ChainAPI.test.request()
            .asObservable()
            .map { ($0 as! NSDictionary)["origin"] as! String }
            .catchAndReturn("") // Exception thrown
    }
    
    func requestData(_ ip: String) -> Observable<NSDictionary> {
        return ChainAPI.test2(ip).request()
            .asObservable()
            .map { ($0 as! NSDictionary) }
            .catchAndReturn(["data": "nil"])
    }
}
```

- Batch Example 5:

```
class BatchViewModel: NSObject {
    let disposeBag = DisposeBag()
    let data = PublishRelay<NSDictionary>()
    
    /// Configure loading animation plugin
    let APIProvider: MoyaProvider<MultiTarget> = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 30
        let session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        let loading = NetworkLoadingPlugin.init()
        return MoyaProvider<MultiTarget>(session: session, plugins: [loading])
    }()
    
    func batchLoad() {
        Observable.zip(
            APIProvider.rx.request(api: BatchAPI.test).asObservable(),
            APIProvider.rx.request(api: BatchAPI.test2("666")).asObservable(),
            APIProvider.rx.request(api: BatchAPI.test3).asObservable()
        ).subscribe(onNext: { [weak self] in
            guard var data1 = $0 as? Dictionary<String, Any>,
                  let data2 = $1 as? Dictionary<String, Any>,
                  let data3 = $2 as? Dictionary<String, Any> else {
                      return
                  }
            data1 += data2
            data1 += data3
            self?.data.accept(data1)
        }, onError: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
    }
}
```
