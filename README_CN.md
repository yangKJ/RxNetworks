# Booming

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks)
[![Releases Compatible](https://img.shields.io/github/release/yangKJ/Booming.svg?style=flat&label=Releases&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks/releases)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Booming.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RxNetworks)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)](#installation)

<font color=red>**🧚. RxSwift + Moya + HandyJSON/Codable + Plugins.👒👒👒**</font>

-------

[**English**](README.md) | 简体中文

基于 **RxSwift + Moya** 搭建响应式数据绑定网络API架构

### 内置插件
该模块主要就是基于moya封装网络相关插件

- 目前已封装14款插件供您使用：
    - [Header](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkHttpHeaderPlugin.swift): 配置请求头插件
    - [Debugging](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkDebuggingPlugin.swift): 网络打印，内置插件
    - [GZip](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkGZipPlugin.swift): 解压缩插件
    - [Shared](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkSharedPlugin.swift): 网络共享插件
    - [Files](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkFilesPlugin.swift): 网络下载文件和上传资源插件
    - [Token](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkTokenPlugin.swift): Token令牌注入验证插件
    - [Ignore](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkIgnorePlugin.swift): 忽略默认插件
    - [Authentication](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkAuthenticationPlugin.swift): 拦截器插件
    - [Cache](https://github.com/yangKJ/RxNetworks/blob/master/Cache/NetworkCachePlugin.swift): 网络数据缓存插件
    - [CustomCache](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkCustomCachePlugin.swift): 自定义网络数据缓存插件
    - [Lottie](https://github.com/yangKJ/RxNetworks/blob/master/Lottie/AnimatedLoadingPlugin.swift): 基于lottie动画加载插件
    
iOS 系统:    
- [Loading](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Huds/NetworkLoadingPlugin.swift): 加载动画插件
- [Warning](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Huds/NetworkWarningPlugin.swift): 网络失败提示插件
- [Indicator](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Views/NetworkIndicatorPlugin.swift): 指示器插件

    
简单使用，在API协议当中实现该协议方法，然后将插件加入其中即可：

```
var plugins: APIPlugins {
    let cache = NetworkCachePlugin.init(options: .cacheThenNetwork)
    let loading = NetworkLoadingPlugin.init(options: .init(delay: 0.5))
    let warning = NetworkWarningPlugin.init()
    let shared = NetworkSharedPlugin.init()
    let gzip = NetworkGZipPlugin.init()
    return [loading, cache, warning, shared, gzip]
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

### HollowCodable
这个模块是序列化和反序列化数据，取代HandyJSON。

🎷 - 结合网络部分使用示例：

```
func request(_ count: Int) -> Observable<[CodableModel]> {
    CodableAPI.cache(count)
        .request(callbackQueue: DispatchQueue(label: "request.codable"))
        .deserialized(ApiResponse<[CodableModel]>.self, mapping: CodableModel.self)
        .compactMap({ $0.data })
        .observe(on: MainScheduler.instance)
        .catchAndReturn([])
}
```

### 如何使用

这边提供多种多样的使用方案供您选择，怎么选择就看你心情；

🎷 - 面向对象使用示例1:

```
class OOViewModel: NSObject {
    let disposeBag = DisposeBag()
    let data = PublishRelay<String>()
    
    func loadData() {
        var api = NetworkAPIOO.init()
        api.cdy_ip = BoomingSetup.baseURL
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
        return BoomingSetup.baseURL
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

### CocoaPods Install
```
Ex: 导入网络架构API
- pod 'Booming'

Ex: 导入加载动画插件
- pod 'Booming'
- pod 'Booming/Plugins/Huds'

Ex: 导入数据解析
- pod 'RxNetworks/HandyJSON'

Ex: 导入响应式模块
- pod 'RxNetworks/RxSwift'

```

### 关于作者
- 🎷 **邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸 **GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺 **掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻 **简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

----

当然如果您这边觉得好用对你有所帮助，请给作者一点辛苦的打赏吧。再次感谢感谢！！！  
有空我也会一直更新维护优化 😁😁😁

<p align="left">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bfb6d859b345472aa3a4bf224dee5969~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=828&h=828&s=112330&e=jpg&b=59be6d" width=30% hspace="1px">
<img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6f4bb3a1b49d427fbe0405edc6b7f7ee~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1200&h=1200&s=185343&e=jpg&b=3977f5" width=30% hspace="15px">
</p>

**救救孩子吧，谢谢各位老板。**

🥺

-----
