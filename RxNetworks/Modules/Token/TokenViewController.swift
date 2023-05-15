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
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: textView.frame.maxY + 50, width: 200, height: 200)
        button.center = CGPoint(x: textView.center.x, y: button.center.y)
        button.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        button.layer.cornerRadius = 100
        button.layer.masksToBounds = true
        button.setTitle("Clear token", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.addTarget(self, action: #selector(thouch(_:)), for: UIControl.Event.touchUpInside)
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
        TokenPlugin.shared.hasToken.accept("")
    }
}
