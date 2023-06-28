//
//  SharedViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks
import RxCocoa

class SharedViewController: BaseViewController<SharedViewModel> {
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 200)
        let view = UITextView.init(frame: rect)
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.defaultTint
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupBindings()
    }
    
    func setupUI() {
        self.view.addSubview(textView)
    }
    
    func setupBindings() {
        viewModel.data
            .bind(to: self.textView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.testImitateMoreNetwork()
    }
}
