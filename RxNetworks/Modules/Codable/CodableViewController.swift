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
        //let rect = CGRect(x: 20, y: 100, width: view.bounds.size.width-40, height: view.bounds.size.height-150)
        let view = UITextView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    func setupBindings() {
        let input = CodableViewModel.Input(count: 5)
        
        let output = viewModel.transform(input: input)
        
        output.items.subscribe(onNext: { [weak self] (datas) in
            self?.textView.textColor = datas.first?.color
            self?.textView.text = try? datas.toJSONString(CodableModel.self, prettyPrint: true)
        }).disposed(by: disposeBag)
    }
}
