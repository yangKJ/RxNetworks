//
//  BatchViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class BatchViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<Dictionary<String, Any>>()
    
    func batchLoad() {
        Observable.zip(
            BatchAPI.test.request(),
            BatchAPI.test2("666").request(),
            BatchAPI.test3.request()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] in
            NetworkLoadingPlugin.hideMBProgressHUD()
            guard var data1 = $0 as? Dictionary<String, Any>,
                  let data2 = $1 as? Dictionary<String, Any>,
                  let data3 = $2 as? Dictionary<String, Any> else {
                return
            }
            data1 += data2
            data1 += data3
            self?.data.onNext(data1)
        }, onError: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
    }
}

extension BatchViewModel {
    
    func testZipData() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        // 序列最多支持8个
        // 都收到新元素，才会发出
        Observable.zip(subject1, subject2)
            .map { "zip: " + $0 + " - " + $1 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        // 任何一个 Observable 发出一个元素，都会发出
        Observable.combineLatest(subject1, subject2)
            .map { "combineLatest: " + $0 + " - " + $1 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        // 某一个 Observable 发出一个元素时，就会将这个元素发出
        // 上下刷新会使用到此功能点
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print("merge: " + $0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("1")
        subject2.onNext("A")
        
        subject2.onNext("B")
        
        print("\n--- After a second ---")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            subject1.onNext("3")
            subject2.onNext("C")
        }
    }
}
