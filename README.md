# RxNetworks

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks)
[![Releases Compatible](https://img.shields.io/github/release/yangKJ/RxNetworks.svg?style=flat&label=Releases&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/RxNetworks/releases)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxNetworks.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RxNetworks)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)

**[RxNetworks](https://github.com/yangKJ/RxNetworks)** is a declarative and reactive networking library for Swift. Developed for Swift 5, it aims to make use of the latest language features. The framework's ultimate goal is to enable easy networking that makes it easy to write well-maintainable code.

<font color=red>**🧚. RxSwift + Moya + HandyJSON + Plugins.👒👒👒**</font>

-------

English | [**简体中文**](README_CN.md)

This is a network api set of infrastructure based on Moya, also support responsive network with RxSwift.

## Features
At the moment, the most important features of RxNetworks can be summarized as follows:

- [x] Support reactive network requests combined with [RxSwift](https://github.com/ReactiveX/RxSwift).
- [x] Support for OOP also support POP network requests.
- [x] Support data parsing with [HandyJSON](https://github.com/alibaba/HandyJSON).
- [x] Support configuration of general request and path, general parameters, etc.
- [x] Support simple customization of various network plugins for [Moya](https://github.com/Moya/Moya).
- [x] Support for injecting default plugins.
- [x] Support 8 plugins have been packaged for you to use.

### Usages
How to use [USAGE](USAGE.md).

```
SharedAPI.loading("Condy").HTTPRequest(success: { _ in
    // do somthing..
}, failure: { _ in
    
})
```

### Plugins
This module is mainly based on moya package network related plugins.

- At present, 8 plugins have been packaged for you to use:
    - [Cache](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Cache/NetworkCachePlugin.swift): Network Data Cache Plugin.
    - [Loading](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Loading/NetworkLoadingPlugin.swift): Load animation plugin.
    - [Indicator](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Indicator/NetworkIndicatorPlugin.swift): Indicator plugin.
    - [Warning](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Warning/NetworkWarningPlugin.swift): Network failure prompt plugin.
    - [Debugging](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Debugging/NetworkDebuggingPlugin.swift): Network printing, built in plugin.
    - [GZip](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/GZip/NetworkGZipPlugin.swift): Network data unzip plugin.
    - [Shared](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/Shared/NetworkSharedPlugin.swift): Network sharing plugin.
    - [AnimatedLoading](https://github.com/yangKJ/RxNetworks/blob/master/Sources/Plugins/AnimatedLoading/AnimatedLoadingPlugin.swift): Animation loading plugin based on lottie.

🏠 Simple to use, implement the protocol method in the API protocol, and then add the plugin to it:

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

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager. For usage and installation instructions, visit their website. To integrate using CocoaPods, specify it in your Podfile:

```
pod 'RxNetworks'
```

You should define your minimum deployment target explicitly, like: 

```
platform :ios, '10.0'
```

If you only want import cache plugin:

```
pod 'RxNetworks/Plugins/Cache'
```

OR can use exclusion method add module.

Ex: You don't need indicator plugin, It can be added in Podfile.

```
ENV["RXNETWORKS_PLUGINGS_EXCLUDE"] = "INDICATOR"
```

For other plugins and modules excluded, please read the [podspec](https://github.com/yangKJ/RxNetworks/blob/master/RxNetworks.podspec) file.

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
RxNetworks is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.

-----
