# Booming

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Booming.svg?style=flat&label=Booming&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/Booming)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxNetworks.svg?style=flat&label=RxNetworks&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RxNetworks)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/HollowCodable.svg?style=flat&label=HollowCodable&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/HollowCodable)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)

**[Booming](https://github.com/yangKJ/RxNetworks)** is a base network library for Swift. Developed for Swift 5, it aims to make use of the latest language features. The framework's ultimate goal is to enable easy networking that makes it easy to write well-maintainable code.

**[RxNetworks](https://github.com/yangKJ/RxNetworks)** is a declarative and reactive networking library for Swift.

<font color=red>**🧚. RxSwift + Moya + HandyJSON / Codable + Plugins.👒👒👒**</font>

-------

English | [**简体中文**](README_CN.md)

This is a network api set of infrastructure based on Moya, also support responsive network with RxSwift.

## Features
At the moment, the most important features of Booming can be summarized as follows:

- [x] Support reactive network requests combined with [RxSwift](https://github.com/ReactiveX/RxSwift).
- [x] Support for [OOP](https://github.com/yangKJ/RxNetworks/blob/master/Booming/NetworkAPIOO.swift) also support [POP](https://github.com/yangKJ/RxNetworks/blob/master/Booming/NetworkAPI.swift) network requests.
- [x] Support data parsing with [HandyJSON](https://github.com/alibaba/HandyJSON) and [Codable](https://github.com/yangKJ/HollowCodable).
- [x] Support simple customization of various network plugins for [Moya](https://github.com/Moya/Moya).
- [x] Support uploading and downloading files or resources [plugin](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkFilesPlugin.swift).
- [x] Support configuration of general request and path, general parameters, etc.
- [x] Support for added default plugins with `BoomingSetup.basePlugins`.
- [x] Support authorization certificate [plugin](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkAuthenticationPlugin.swift) with Alamofire [RequestInterceptor](https://github.com/Alamofire/Alamofire/blob/master/Source/Features/RequestInterceptor.swift).
- [x] Support automatic managed [loading](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Huds/NetworkLoadingPlugin.swift) plugins hud.
- [x] Support token [plugin](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkTokenPlugin.swift) validation and automatically retries new token requests.
- [x] Support shared [plugin](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkSharedPlugin.swift) that do not request the same network repeatedly.
- [x] Support separate plugin library, eg: [Loading](https://cocoapods.org/pods/NetworkHudsPlugin) / [AnimatedLoading](https://cocoapods.org/pods/NetworkLottiePlugin) / [Cache](https://cocoapods.org/pods/NetworkCachePlugin).
- [x] Support 18 plugins have been packaged for you to use.

### Usages
How to use [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md).

```
SharedAPI.userInfo(name: "yangKJ").request(successed: { response in
    // do somthing..
}, failed: { error in
    print(error.localizedDescription)
})

or use async/await with swift 5.5

Task {
    do {
        let response = try await LoadingAPI.test2("666").requestAsync()
        let json = response.bpm.mappedJson
        // do somthing..
    } catch {
        block(error.localizedDescription)
    }
}
```

### Plugins
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NetworkHudsPlugin.svg?style=flat&label=NetworkHudsPlugin&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/NetworkHudsPlugin)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NetworkCachePlugin.svg?style=flat&label=NetworkCachePlugin&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/NetworkCachePlugin)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NetworkLottiePlugin.svg?style=flat&label=NetworkLottiePlugin&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/NetworkLottiePlugin)

This module is mainly based on moya package network related plugins.

- At present, 14 plugins have been packaged for you to use:
    - [Header](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkHttpHeaderPlugin.swift): Network HTTP Header Plugin.
    - [Authentication](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkAuthenticationPlugin.swift): Interceptor plugin.
    - [Debugging](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkDebuggingPlugin.swift): Network printing, built in plugin.
    - [GZip](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkGZipPlugin.swift): Network data unzip plugin.
    - [Shared](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkSharedPlugin.swift): Network sharing plugin.
    - [Files](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkFilesPlugin.swift): Network downloading files And Uploading resources plugin.
    - [Token](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkTokenPlugin.swift): Token verify plugin.
    - [Ignore](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkIgnorePlugin.swift): Ignore plugin, the purpose is to ignore a plugin in this network request.
    - [CustomCache](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Features/NetworkCustomCachePlugin.swift): Custom network data caching plugin.
    - [Cache](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Cache/NetworkCachePlugin.swift): Network data cache plugin.
    - [Lottie](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Lottie/AnimatedLoadingPlugin.swift): Animation loading plugin based on lottie.
    
For ios platform:    
- [Loading](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Huds/NetworkLoadingPlugin.swift): Loading animation plugin.
- [Warning](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Huds/NetworkWarningPlugin.swift): Network failure prompt plugin.
- [Indicator](https://github.com/yangKJ/RxNetworks/blob/master/Plugins/Views/NetworkIndicatorPlugin.swift): Indicator plugin.

If you want to use token plugin and auth plugin you can refer to the project use case.    
- [Auth](https://github.com/yangKJ/RxNetworks/blob/master/RxNetworks/Plugins/Auth/AuthPlugin.swift): Authorization plugin.

🎷 Simple to use, implement the protocol method in the API protocol, and then add the plugin to it:

```
var plugins: APIPlugins {
    let cache = NetworkCachePlugin.init()
    let loading = NetworkLoadingPlugin.init()
    let warning = NetworkWarningPlugin.init()
    let shared = NetworkSharedPlugin.init()
    let gzip = NetworkGZipPlugin.init()
    return [loading, cache, warning, shared, gzip]
}
```

### RxSwift
This module mainly supports responsive data binding.

```
func request(_ count: Int) -> Observable<[CacheModel]> {
    CacheAPI.cache(count).request()
        .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
        .compactMap { $0.data }
        .observe(on: MainScheduler.instance)
        .catchAndReturn([])
}
```

### HandyJSON
This module is based on `HandyJSON` package network data parsing.

- Roughly divided into the following 3 parts:
    - [HandyDataModel](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyDataModel.swift): Network outer data model.
    - [HandyJSONError](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/HandyJSONError.swift): Parse error related.
    - [RxHandyJSON](https://github.com/yangKJ/RxNetworks/blob/master/Sources/HandyJSON/RxHandyJSON.swift): HandyJSON data parsing, currently provides two parsing solutions.
        - **Option 1**: Combine `HandyDataModel` model to parse out data.
        - **Option 2**: Parse the data of the specified key according to `keyPath`, the precondition is that the json data source must be in the form of a dictionary.

🎷 Example of use in conjunction with the network part:

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

### HollowCodable
**[HollowCodable](https://github.com/yangKJ/HollowCodable)** is a codable customization using property wrappers library for Swift.

This module is serialize and deserialize the data, Replace HandyJSON.

🎷 Example of use in conjunction with the network part:

```
func request(_ count: Int) -> Observable<[CodableModel]> {
    CodableAPI.cache(count)
        .request(callbackQueue: DispatchQueue(label: "request.codable"))
        .deserialized(ApiResponse<[CodableModel]>.self)
        .compactMap({ $0.data })
        .observe(on: MainScheduler.instance)
        .catchAndReturn([])
}

public extension Observable where Element: Any {
    
    @discardableResult func deserialized<T: HollowCodable>(_ type: T.Type) -> Observable<T> {
        return self.map { element -> T in
            return try T.deserialize(element: element)
        }
    }
}
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager. For usage and installation instructions, visit their website. To integrate using CocoaPods, specify it in your Podfile:

```
pod 'Booming'
```

You should define your minimum deployment target explicitly, like: 

```
platform :ios, '11.0'
```

If you want import cache plugin:

```
pod 'NetworkCachePlugin'
```

If you want import loading plugin:

```
pod 'NetworkHudsPlugin'
```

If you wang using Codable:

```
pod 'HollowCodable'
```

If responsive networking is required:

```
pod 'RxNetworks/RxSwift'
```

For other plugins and modules excluded, please read the [podspec](https://github.com/yangKJ/RxNetworks/blob/master/Booming.podspec) file.

### Remarks

> The general process is almost like this, the Demo is also written in great detail, you can check it out for yourself.🎷
>
> [**BoomingDemo**](https://github.com/yangKJ/RxNetworks)
>
> Tip: If you find it helpful, please help me with a star. If you have any questions or needs, you can also issue.
>
> Thanks.🎇

### About the author
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

Buy me a coffee or support me on [GitHub](https://github.com/sponsors/yangKJ?frequency=one-time&sponsor=yangKJ).

<a href="https://www.buymeacoffee.com/yangkj3102">
<img width=25% alt="yellow-button" src="https://user-images.githubusercontent.com/1888355/146226808-eb2e9ee0-c6bd-44a2-a330-3bbc8a6244cf.png">
</a>

Alipay or WeChat. Thanks.

<p align="left">
<img src="https://raw.githubusercontent.com/yangKJ/Harbeth/master/Screenshot/WechatIMG1.jpg" width=30% hspace="1px">
<img src="https://raw.githubusercontent.com/yangKJ/Harbeth/master/Screenshot/WechatIMG2.jpg" width=30% hspace="15px">
</p>

-----

### License
Booming is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.

-----
