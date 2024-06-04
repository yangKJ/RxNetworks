//
//  CustomCacheViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import CacheX

class CustomCacheViewModel: NSObject {

    struct Input {
        let count: Int
    }

    struct Output {
        let items: Observable<CacheModel>
    }
    
    func transform(input: Input) -> Output {
        let items = request(input.count).asObservable()
        
        return Output(items: items)
    }
    
    lazy var storage: CacheX.Storage<CacheXCodable> = {
        /// Create a unified background processing thread.
        let background = DispatchQueue(label: "com.condy.booming.cached.queue.\(UUID().uuidString)", attributes: [.concurrent])
        var disk = Disk.init()
        disk.named = "CustomCached"
        disk.expiry = .seconds(60 * 60 * 24 * 7)
        disk.maxCountLimit = 20 * 1024
        var memory = Memory.init()
        memory.maxCostLimit = 0
        return CacheX.Storage<CacheXCodable>.init(queue: background, caches: [
            Disk.named: disk,
            Memory.named: memory,
        ])
    }()
}

extension CustomCacheViewModel {
    
    func request(_ count: Int) -> Observable<CacheModel> {
        let cache = NetworkCustomCachePlugin(cacheType: .cacheThenNetwork, cacher: storage)
        return CustomCacheAPI.cache(count).request(plugins: [cache])
            .mapHandyJSON(CacheModel.self)
            .observe(on: MainScheduler.instance)
    }
}
