//
//  LoadingViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

class LoadingViewController: BaseViewController<LoadingViewModel> {
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 200)
        let view = UITextView.init(frame: rect)
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.defaultTint
        self.view.addSubview(view)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupBindings()
    }
    
    func setupBindings() {
        viewModel.data
            .asObservable()
            .map { $0["data"] as? String }
            .subscribe(onNext: { [weak self] in
                self?.textView.text = $0
            })
            .disposed(by: disposeBag)

        viewModel.loadData()
    }
}
