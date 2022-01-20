# RxNetworks

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks)
[![Releases Compatible](https://img.shields.io/github/release/yangKJ/RxNetworks.svg?style=flat&label=Releases&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks/releases)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxNetworks.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RxNetworks)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)](#installation)

<font color=red>**🧚. RxSwift + Moya + HandyJSON + Plugins.👒👒👒**</font>

-------

English | [**简体中文**](README_CN.md)

This is a set of infrastructure based on `RxSwift + Moya`

### MoyaNetwork
This module is based on the Moya encapsulated network API architecture.

- Mainly divided into 3 parts:
    - [NetworkConfig](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkConfig.swift): Set the configuration information at the beginning of the program.
        - **baseURL**: Root path address to base URL.
        - **baseParameters**: Default basic parameters, like: userID, token, etc.
        - **baseMethod**: Default request method type.
        - **updateBaseParametersWithValue**: Update default base parameter value.
    - [RxMoyaProvider](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/RxMoyaProvider.swift): Add responsiveness to network requests, returning `Single` sequence.
    - [NetworkUtil](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkUtil.swift): Network related functions
         - **defaultPlugin**: Add default plugin.
         - **transformAPISingleJSON**: Transforms a `Single` sequence object.
         - **handyConfigurationPlugin**: Handles configuration plugins.
	- [PluginSubType](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/PluginSubType.swift): Inherit and replace the Moya plug-in protocol to facilitate subsequent expansion.
         - **configuration**: After setting the network configuration information, before starting to prepare the request, this method can be used in scenarios such as key invalidation, re-acquiring the key and then automatically re-requesting the network.
         - **lastNever**: When the last network response is returned, this method can be used in scenarios such as key failure to re-obtain the key and then automatically re-request the network.
    - [NetworkAPI](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkAPI.swift): Add protocol attributes and encapsulate basic network requests based on TargetType.
        - **ip**: Root path address to base URL.
        - **parameters**: Request parameters.
        - **plugins**: Set network plugins.
        - **stubBehavior**: Whether to take the test data.
        - **request**: Network request method and return a Single sequence object.
	- [NetworkAPIOO](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkAPIOO.swift): OOP converter, MVP to OOP, convenient for friends who are used to OC thinking
        - **cdy_ip**: Root path address to base URL.
        - **cdy_path**: Request path.
        - **cdy_parameters**: Request parameters.
        - **cdy_plugins**: Set network plugins.
        - **cdy_testJSON**: Network testing json string.
        - **cdy_testTime**: Network test data return time, the default is half a second.
        - **cdy_HTTPRequest**: Network request method and return a Single sequence object.
    - [NetworkX](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkX.swift): extension function methods etc.
        - **toJSON**: to JSON string.
        - **toDictionary**: JSON string to dictionary.
        - **+=**: Dictionary concatenation.

🎷 - OO Example 1:

```
class OOViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<String>()
    
    func loadData() {
        var api = NetworkAPIOO.init()
        api.cdy_ip = NetworkConfig.baseURL
        api.cdy_path = "/ip"
        api.cdy_method = .get
        api.cdy_plugins = [NetworkLoadingPlugin.init()]
        
        api.cdy_HTTPRequest()
            .asObservable()
            .compactMap{ (($0 as! NSDictionary)["origin"] as? String) }
            .bind(to: data)
            .disposed(by: disposeBag)
    }
}
```

🎷 - MVP Example 2:

```
enum LoadingAPI {
    case test2(String)
}

extension LoadingAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var path: String {
        return "/post"
    }
    
    var parameters: APIParameters? {
        switch self {
        case .test2(let string): return ["key": string]
        }
    }
}


class LoadingViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<NSDictionary>()
    
    /// Configure the loading animation plugin
    let APIProvider: MoyaProvider<MultiTarget> = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 30
        let session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        let loading = NetworkLoadingPlugin.init()
        return MoyaProvider<MultiTarget>(session: session, plugins: [loading])
    }()
    
    func loadData() {
        APIProvider.rx.request(api: LoadingAPI.test2("666"))
            .asObservable()
            .subscribe { [weak self] (event) in
                if let dict = event.element as? NSDictionary {
                    self?.data.accept(dict)
                }
            }.disposed(by: disposeBag)
    }
}
```

🎷 - MVVM Example 3:

```
class CacheViewModel: NSObject {

    let disposeBag = DisposeBag()
    
    struct Input {
        let count: Int
    }

    struct Output {
        let items: Driver<[CacheModel]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[CacheModel]>(value: [])
        
        let output = Output(items: elements.asDriver())
        
        request(input.count)
            .asObservable()
            .bind(to: elements)
            .disposed(by: disposeBag)
        
        return output
    }
}

extension CacheViewModel {
    
    func request(_ count: Int) -> Driver<[CacheModel]> {
        CacheAPI.cache(count).request()
            .asObservable()
            .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance)
            .delay(.seconds(1), scheduler: MainScheduler.instance) 
            .asDriver(onErrorJustReturn: [])
    }
}
```

🎷 - Chain Example 4:

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

🎷 - Batch Example 5:

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
        Single.zip(
            APIProvider.rx.request(api: BatchAPI.test),
            APIProvider.rx.request(api: BatchAPI.test2("666")),
            APIProvider.rx.request(api: BatchAPI.test3)
        ).subscribe(onSuccess: { [weak self] in
            guard var data1 = $0 as? Dictionary<String, Any>,
                  let data2 = $1 as? Dictionary<String, Any>,
                  let data3 = $2 as? Dictionary<String, Any> else {
                      return
                  }
            data1 += data2
            data1 += data3
            self?.data.accept(data1)
        }, onFailure: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
    }
}
```


### MoyaPlugins
This module is mainly based on moya package network related plug-ins

- At present, 4 plug-ins have been packaged for you to use:
    - [Cache](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Cache/NetworkCachePlugin.swift): Network Data Cache Plugin
    - [Loading](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Loading/NetworkLoadingPlugin.swift): Load animation plugin
    - [Indicator](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Indicator/NetworkIndicatorPlugin.swift): Indicator plugin
    - [Warning](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Warning/NetworkWarningPlugin.swift): Network failure prompt plugin

🏠 - Simple to use, implement the protocol method in the API protocol, and then add the plugin to it:

```
var plugins: APIPlugins {
    let cache = NetworkCachePlugin(cacheType: .networkElseCache)
    let loading = NetworkLoadingPlugin.init(delayHideHUD: 0.5)
    return [loading, cache]
}
```

### HandyJSON
This module is based on `HandyJSON` package network data parsing

- Roughly divided into the following 3 parts:
    - [HandyDataModel](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyDataModel.swift): Network outer data model
    - [HandyJSONError](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyJSONError.swift): Parse error related
    - [RxHandyJSON](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/RxHandyJSON.swift): HandyJSON data parsing, currently provides two parsing solutions
        - **Option 1**: Combine `HandyDataModel` model to parse out data.
        - **Option 2**: Parse the data of the specified key according to `keyPath`, the precondition is that the json data source must be in the form of a dictionary.

🎷 - Example of use in conjunction with the network part:

```
func request(_ count: Int) -> Driver<[CacheModel]> {
    CacheAPI.cache(count).request()
        .asObservable()
        .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
        .compactMap { $0.data }
        .observe(on: MainScheduler.instance)
        .delay(.seconds(1), scheduler: MainScheduler.instance)
        .asDriver(onErrorJustReturn: [])
}
```

### CocoaPods Install
```
Ex: Import Network Architecture API
- pod 'RxNetworks/MoyaNetwork'

Ex: Import Model Anslysis 
- pod 'RxNetworks/HandyJSON'

Ex: Import loading animation plugin
- pod 'RxNetworks/MoyaPlugins/Loading'
```

### Remarks

> The general process is almost like this, the Demo is also written in great detail, you can check it out for yourself.🎷
>
> [**RxNetworksDemo**](https://github.com/yangKJ/RxNetworks)
>
> Tip: If you find it helpful, please help me with a star. If you have any questions or needs, you can also issue.
>
> Thanks.🎇

### About the author
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

-----

### License
RxNetworks is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.

-----
