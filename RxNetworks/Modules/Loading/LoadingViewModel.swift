//
//  LoadingViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class LoadingViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<NSDictionary>()
    
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
                    self?.data.onNext(dict)
                }
            }.disposed(by: disposeBag)
    }
}
