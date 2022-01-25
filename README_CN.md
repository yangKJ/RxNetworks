# RxNetworks

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks)
[![Releases Compatible](https://img.shields.io/github/release/yangKJ/RxNetworks.svg?style=flat&label=Releases&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks/releases)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxNetworks.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RxNetworks)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)](#installation)

<font color=red>**🧚. RxSwift + Moya + HandyJSON + Plugins.👒👒👒**</font>

-------

[**English**](README.md) | 简体中文

基于 **RxSwift + Moya** 搭建响应式数据绑定网络API架构

### MoyaNetwork
该模块是基于Moya封装的网络API架构

- 主要分为8部分：
    - [NetworkConfig](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkConfig.swift)：在程序最开始处设置配置信息，全局通用
        - **addDebugging**：是否默认引入调试模式插件
        - **baseURL**：根路径地址
        - **baseParameters**：默认基本参数，类似：userID，token等
        - **baseMethod**：默认请求类型
        - **updateBaseParametersWithValue**：更新默认基本参数数据
    - [RxMoyaProvider](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/RxMoyaProvider.swift)：对网络请求添加响应式，返回`Single`序列
    - [NetworkUtil](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkUtil.swift)：网络相关函数
        - **defaultPlugin**：添加默认插件
        - **transformAPIObservableJSON**：转换成可观察序列JSON对象
        - **handyConfigurationPlugin**：处理配置插件
        - **handyLastNeverPlugin**：最后的插件处理
    - [PluginSubType](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/PluginSubType.swift)：继承替换Moya插件协议，方便后序扩展
        - **configuration**：设置网络配置信息之后，开始准备请求之前，该方法可以用于本地缓存存在时直接抛出数据而不用再执行后序网络请求等场景
        - **lastNever**：最后的最后网络响应返回时刻，该方法可以用于密钥失效重新去获取密钥然后自动再次网络请求等场景
    - [NetworkAPI](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkAPI.swift)：在`TargetType`基础上增加协议属性和封装基础网络请求
        - **ip**：根路径地址
        - **parameters**：请求参数
        - **plugins**：插件
        - **stubBehavior**：是否走测试数据
        - **retry**：网络请求失败重试次数
        - **request**：网络请求方法，返回可观察序列JSON对象
    - [NetworkAPI+Ext](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkAPI+Ext.swift): 协议默认实现方案
    - [NetworkAPIOO](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkAPIOO.swift)：面向对象转换器，面向协议模式转面向对象，方便习惯OC思维的小伙伴
        - **cdy_ip**：根路径地址
        - **cdy_path**：请求路径
        - **cdy_parameters**：请求参数
        - **cdy_plugins**：插件
        - **cdy_testJSON**：测试数据
        - **cdy_testTime**：测试数据返回时间，默认半秒
        - **cdy_HTTPRequest**：网络请求方法
    - [NetworkX](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaNetwork/NetworkX.swift)：扩展函数方法等
        - **toJSON**：对象转JSON字符串
        - **toDictionary**：JSON字符串转字典
        - **+=**：字典拼接

🎷 - 面向对象使用示例1:

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

🎷 - MVP使用示例2:

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
    
    /// 配置加载动画插件
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

🎷 - MVVM使用示例3:

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
            .observe(on: MainScheduler.instance) // 结果在主线程返回
            .delay(.seconds(1), scheduler: MainScheduler.instance) // 延时1秒返回
            .asDriver(onErrorJustReturn: []) // 错误时刻返回空
    }
}
```

🎷 - 链式请求使用示例4:

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
            .catchAndReturn("") // 异常抛出
    }
    
    func requestData(_ ip: String) -> Observable<NSDictionary> {
        return ChainAPI.test2(ip).request()
            .asObservable()
            .map { ($0 as! NSDictionary) }
            .catchAndReturn(["data": "nil"])
    }
}
```

🎷 - 批量请求使用示例5:

```
class BatchViewModel: NSObject {
    let disposeBag = DisposeBag()
    let data = PublishRelay<NSDictionary>()
    
    /// 配置加载动画插件
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

### MoyaPlugins
该模块主要就是基于moya封装网络相关插件

- 目前已封装6款插件供您使用：
    - [Cache](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Cache/NetworkCachePlugin.swift)：网络数据缓存插件
    - [Loading](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Loading/NetworkLoadingPlugin.swift)：加载动画插件
    - [Indicator](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Indicator/NetworkIndicatorPlugin.swift)：指示器插件
    - [Warning](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Warning/NetworkWarningPlugin.swift)：网络失败提示插件
    - [Debugging](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/Debugging/NetworkDebuggingPlugin.swift): 网络打印，内置插件
    - [GZip](https://github.com/yangKJ/RxNetworks/blob/master/Sources/MoyaPlugins/GZip/NetworkGZipPlugin.swift): 解压缩插件
    
🏠 - 简单使用，在API协议当中实现该协议方法，然后将插件加入其中即可：

```
var plugins: APIPlugins {
    let cache = NetworkCachePlugin(cacheType: .networkElseCache)
    let loading = NetworkLoadingPlugin.init(delay: 0.5)
    let warning = NetworkWarningPlugin.init()
    warning.changeHud = { (hud) in
        hud.detailsLabel.textColor = UIColor.yellow
    }
    return [loading, cache, warning]
}
```

### HandyJSON
该模块是基于`HandyJSON`封装网络数据解析

- 大致分为以下3个部分：
    - [HandyDataModel](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyDataModel.swift)：网络外层数据模型
    - [HandyJSONError](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyJSONError.swift)：解析错误相关
    - [RxHandyJSON](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/RxHandyJSON.swift)：HandyJSON数据解析，目前提供两种解析方案
        - **方案1** - 结合`HandyDataModel`模型使用解析出`data`数据
        - **方案2** - 根据`keyPath`解析出指定key的数据，前提条件数据源必须字典形式

🎷 - 结合网络部分使用示例：

```
func request(_ count: Int) -> Driver<[CacheModel]> {
    CacheAPI.cache(count).request()
        .asObservable()
        .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
        .compactMap { $0.data }
        .observe(on: MainScheduler.instance) // 结果在主线程返回
        .delay(.seconds(1), scheduler: MainScheduler.instance) // 延时1秒返回
        .asDriver(onErrorJustReturn: []) // 错误时刻返回空
}
```

### CocoaPods Install
```
Ex: 导入网络架构API
- pod 'RxNetworks/MoyaNetwork'

Ex: 导入数据解析
- pod 'RxNetworks/HandyJSON'

Ex: 导入加载动画插件
- pod 'RxNetworks/MoyaPlugins/Loading'
```

-----

> <font color=red>**觉得有帮助的老哥们，请帮忙点个星 ⭐..**</font>

**救救孩子吧，谢谢各位老板。**

🥺 - [**传送门**](https://github.com/yangKJ/RxNetworks)

-----
