//
//  CodableViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2024/5/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import HollowCodable

class CodableViewController: BaseViewController<CodableViewModel> {
    
    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: view.bounds.size.height-150)
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
        let input = CodableViewModel.Input(count: 5)
        
        let output = viewModel.transform(input: input)
        
        output.items.subscribe(onNext: { [weak self] (datas) in
            self?.textView.text = try? datas.toJSONString(CodeableModel.self, prettyPrint: true)
        }).disposed(by: disposeBag)
    }
}
