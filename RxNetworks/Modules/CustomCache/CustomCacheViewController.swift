//
//  CustomCacheViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

class CustomCacheViewController: BaseViewController<CustomCacheViewModel> {

    lazy var textView: UITextView = {
        let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: 400)
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
        let input = CustomCacheViewModel.Input(count: 5)
        
        let output = viewModel.transform(input: input)
        
        output.items.subscribe(onNext: { [weak self] (datas) in
            self?.textView.textColor = Self.random
            self?.textView.text = datas.toJSONString(prettyPrint: true)
        }).disposed(by: disposeBag)
    }
    
    static var random: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
