//
//  TokenViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks
import RxCocoa

class TokenViewController: BaseViewController<TokenViewModel> {
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 300)
        let view = UITextView.init(frame: rect)
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.defaultTint
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: textView.frame.maxY + 50, width: 100, height: 100)
        button.center = CGPoint(x: textView.center.x - 75, y: button.center.y)
        button.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        button.setTitle("Clear token", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(thouch(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var button2: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: textView.frame.maxY + 50, width: 100, height: 100)
        button.center = CGPoint(x: textView.center.x + 75, y: button.center.y)
        button.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        button.setTitle("Request", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.textView.text = nil
            self?.viewModel.loadData()
        }).disposed(by: disposeBag)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupBindings()
    }
    
    func setupUI() {
        self.view.addSubview(textView)
        self.view.addSubview(button)
        self.view.addSubview(button2)
    }
    
    func setupBindings() {
        viewModel.data
            .asObservable()
            .map { $0["headers"] }
            .subscribe(onNext: { [weak self] in
                self?.textView.text = X.toJSON(form: $0 as Any, prettyPrint: true)
            })
            .disposed(by: disposeBag)

        viewModel.loadData()
    }
    
    @objc func thouch(_ sender: UIButton) {
        // 模拟清除token
        TokenManager.shared.setToken("")
    }
}
