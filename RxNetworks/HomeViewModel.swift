//
//  HomeViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2021/10/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift

enum ViewControllerType: String {
    case OO = "OOP Network"
    case Chain = "Chain"
    case Batch = "Batch"
    case Loading = "Loading"
    case Cache = "Cache"
    case Warning = "Warning"
    
    var title: String {
        switch self {
        case .OO: return "面向对象基础网络"
        case .Chain: return "链式串行网络"
        case .Batch: return "批量并行网络"
        case .Loading: return "加载动画"
        case .Cache: return "缓存插件"
        case .Warning: return "错误提示插件"
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .OO: return OOViewController()
        case .Chain: return ChainViewController()
        case .Batch: return BatchViewController()
        case .Loading: return LoadingViewController()
        case .Cache: return CacheViewController()
        case .Warning: return WarningViewController()
        }
    }
}

struct HomeViewModel {

    let datasObservable = Observable<[ViewControllerType]>.just([
        .OO,
        .Chain,
        .Batch,
        .Loading,
        .Cache,
        .Warning,
    ])
}
