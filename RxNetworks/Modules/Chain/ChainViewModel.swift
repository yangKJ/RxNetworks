//
//  ChainViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class ChainViewModel: NSObject {
    
    struct Input { }
    
    struct Output {
        let data: Observable<NSDictionary>
    }
    
    func transform(input: Input) -> Output {
        let data = chain().asObservable()
        
        return Output(data: data)
    }
    
    func chain() -> Observable<NSDictionary> {
        Observable.from(optional: "begin")
            .flatMapLatest(requestIP)
            .flatMapLatest(requestData(ip:))
            .catchAndReturn([:])
    }
}

extension ChainViewModel {
    
    func requestIP(_ stirng: String) -> Observable<String> {
        return ChainAPI.test.request()
            .asObservable()
            .map { (($0 as? NSDictionary)?["origin"] as? String) ?? stirng }
            .observe(on: MainScheduler.instance)
    }
    
    func requestData(ip: String) -> Observable<NSDictionary> {
        return ChainAPI.test2(ip).request()
            .map { ($0 as! NSDictionary) }
            .catchAndReturn(["data": "nil"]) // 异常抛出
            .observe(on: MainScheduler.instance)
    }
}
