//
//  ChainViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks
import RxCocoa

class ChainViewController: BaseViewController<ChainViewModel> {
    
    let throttleEvent: PublishRelay<String> = PublishRelay()
    let debounceEvent: PublishRelay<String> = PublishRelay()
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 200)
        let view = UITextView.init(frame: rect)
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.defaultTint
        self.view.addSubview(view)
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: textView.frame.maxY + 50, width: 200, height: 200)
        button.center = CGPoint(x: textView.center.x, y: button.center.y)
        button.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        button.layer.cornerRadius = 100
        button.layer.masksToBounds = true
        button.setTitle("debounce & throttle", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.addTarget(self, action: #selector(debounceTest), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        self.setupBindings()
    }
    
    func setupBindings() {
        let input = ChainViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.data.subscribe(onNext: { [weak self] dict in
            self?.textView.text = dict["data"] as? String
        }, onError: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
        
        throttleEvent
            .throttle(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance) // 延迟2秒后继续响应
            .subscribe {
                print("throttle: " + $0)
            }.disposed(by: disposeBag)
        
        debounceEvent
            .debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance) // 2秒内点击多次只响应一次
            .subscribe (onNext: {
                print("debounce: " + $0)
            }, onCompleted: {
                print("onCompleted")
            }).disposed(by: disposeBag)
    }
    
    @objc func debounceTest() {
        self.throttleEvent.accept("123")
        self.debounceEvent.accept("2345678")
    }
    
}
