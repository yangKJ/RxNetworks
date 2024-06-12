//
//  OOViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks
import RxCocoa

class OOViewController: BaseViewController<OOViewModel> {
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 400)
        let view = UITextView.init(frame: rect)
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.defaultTint
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: textView.frame.maxY + 30, width: 120, height: 120)
        button.center = CGPoint(x: textView.center.x, y: button.center.y)
        button.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        button.layer.cornerRadius = 60
        button.layer.masksToBounds = true
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.request()
        }).disposed(by: disposeBag)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(button)
        self.view.addSubview(textView)
        
        self.request()
    }
    
    func request() {
        viewModel.request { [weak self] text in
            self?.textView.text = text
        }
    }
}
