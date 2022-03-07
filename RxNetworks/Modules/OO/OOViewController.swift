//
//  OOViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

class OOViewController: BaseViewController<OOViewModel> {

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
        button.addTarget(self, action: #selector(thouch(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc func thouch(_ sender: UIButton) {
        // 操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。
        // 然后将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。以此类推，直到遍历完全部的元素
        Observable.of(10, 100, 1000, 23)
            .scan(1) { $0 + $1 }
            .subscribe(onNext: { print("scan: " + "\($0)") })
            .disposed(by: disposeBag)
        
        // 操作符将对第一个元素应用一个函数。然后将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果
        Observable.of(10, 100, 1000, 23)
            .reduce(1, accumulator: +)
            .subscribe(onNext: { print("reduce: " + "\($0)") })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
        self.setupBindings()
    }
    
    func setupBindings() {
        let input = OOViewModel.Input(retry: 3)
        
        let output = viewModel.transform(input: input)
        
        output.items.subscribe(onNext: { [weak self] (text) in
            self?.textView.text = text
        }).disposed(by: disposeBag)
    }
}
