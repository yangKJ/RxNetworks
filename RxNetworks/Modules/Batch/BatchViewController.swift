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
    
    @objc func thouch(_ sender: UIButton) {
        viewModel.testZipData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
        self.setupBindings()
    }
    
    func setupBindings() {
        viewModel.data.subscribe { [weak self] dict in
            self?.textView.text = X.toJSON(form: dict.element as Any, prettyPrint: true)
        }.disposed(by: disposeBag)

        viewModel.batchLoad()
    }
}
