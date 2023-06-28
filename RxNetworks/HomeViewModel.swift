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
    case Closure = "Network request in closure mode"
    case OO = "OO Basic Network"
    case Chain = "Chained Serial Network"
    case Batch = "Batch Parallel Network"
    case Loading = "Loading Animation Plugin"
    case Cache = "Cache Network Plugin"
    case Warning = "Failed Prompting Plugin"
    case GZip = "GZip UnCompression Plugin"
    case AnimatedLoading = "Lottie Animated Loading Plugin"
    case Token = "Simulation Token Plugin"
    case Shared = "Shared Network Plugin"
    
    func viewController() -> UIViewController {
        switch self {
        case .Closure:
            return ClosureViewController()
        case .OO:
            return OOViewController()
        case .Chain:
            return ChainViewController()
        case .Batch:
            return BatchViewController()
        case .Loading:
            return LoadingViewController()
        case .Cache:
            return CacheViewController()
        case .Warning:
            return WarningViewController()
        case .GZip:
            return GZipViewController()
        case .AnimatedLoading:
            return AnimatedLoadingViewController()
        case .Token:
            return TokenViewController()
        case .Shared:
            return SharedViewController()
        }
    }
}

struct HomeViewModel {
    
    lazy var datas: [ViewControllerType] = {
        return [
            .Closure,
            .OO,
            .Chain,
            .Batch,
            .Loading,
            .AnimatedLoading,
            .Cache,
            .Warning,
            .GZip,
            .Token,
            .Shared,
        ]
    }()
}
