//
//  BatchViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

class BatchViewController: BaseViewController<BatchViewModel> {
    
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
        button.setTitle("Many zip data", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.addTarget(self, action: #selector(thouch(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
        self.setupBindings()
    }
    
    func setupBindings() {
        let input = BatchViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.data.subscribe(onNext: { [weak self] dict in
            self?.textView.text = X.toJSON(form: dict as Any, prettyPrint: true)
        }, onError: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
    }
    
    @objc func thouch(_ sender: UIButton) {
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
        
        // 某一个 Observable 发出一个元素时，就会将这个元素发出，响应一次发一个
        // 上下刷新会使用到此功能点
        Observable.of(subject1, subject2).merge()
            .map { "merge: " + $0 }
            .subscribe(onNext: { print($0) })
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
